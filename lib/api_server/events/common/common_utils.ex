defmodule ApiServer.Events.CommonUtils do
  defp remove_nil_values(map) do
    map
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> case do
      [] -> nil
      list -> Enum.into(list, %{})
    end
  end

  defp get_user_agent_browser(user_agent) do
    user_agent
    |> Map.get(:browser)
    |> case do
      nil ->
        nil

      browser ->
        %{
          "name" => Map.get(browser, :family),
          "version" => Map.get(browser, :version_string)
        }
        |> remove_nil_values
    end
  end

  defp get_user_agent_os(user_agent) do
    user_agent
    |> Map.get(:os)
    |> case do
      nil ->
        nil

      os ->
        %{
          "name" => Map.get(os, :family),
          "version" => Map.get(os, :version_string)
        }
        |> remove_nil_values
    end
  end

  defp get_user_agent_device(user_agent) do
    user_agent
    |> Map.get(:device)
    |> case do
      nil ->
        nil

      device ->
        %{
          "family" => Map.get(device, :family),
          "model" => Map.get(device, :model),
          "brand" => Map.get(device, :brand)
        }
        |> remove_nil_values
    end
  end

  def parse_contexts(payload) do
    user_agent_string = get_in(payload, ["request", "headers", "User-Agent"])

    case user_agent_string do
      nil ->
        nil

      _ ->
        user_agent = UAParser.parse(user_agent_string)

        %{
          "os" => Map.get(payload, "os", get_user_agent_os(user_agent)),
          "device" => Map.get(payload, "device", get_user_agent_device(user_agent)),
          "browser" => Map.get(payload, "browser", get_user_agent_browser(user_agent))
        }
        |> remove_nil_values()
    end
  end

  def parse_tags(payload, contexts) do
    browser = Map.get(contexts, "browser", %{})

    browser_tags =
      if not Map.has_key?(browser, "name") do
        nil
      else
        %{
          "browser.name" => Map.get(browser, "name"),
          "browser" => "#{Map.get(browser, "name")} #{Map.get(browser, "version")}"
        }
        |> remove_nil_values()
      end

    os_tags =
      %{
        "os.name" => get_in(contexts, ["os", "name"])
      }
      |> remove_nil_values()

    device_tags =
      %{
        "device" => get_in(contexts, ["device", "model"])
      }
      |> remove_nil_values()

    user_tags =
      %{
        "user.id" => get_in(contexts, ["user", "id"]),
        "user.email" => get_in(contexts, ["user", "email"]),
        "user.username" => get_in(contexts, ["user", "username"])
      }
      |> remove_nil_values()

    server_tags = Map.get(payload, "server")
    release_tags = Map.get(payload, "release")
    environment_tags = Map.get(payload, "environment")

    %{
      "os" => os_tags,
      "user" => user_tags,
      "device" => device_tags,
      "server" => server_tags,
      "browser" => browser_tags,
      "release" => release_tags,
      "environment" => environment_tags
    }
    |> remove_nil_values()
  end

  def get_path(data, []), do: {data, []}

  def get_path(data, [key | rst] = keys) do
    cond do
      is_map(data) && Map.has_key?(data, key) ->
        get_path(Map.get(data, key), rst)

      is_list(data) && is_integer(key) ->
        case Enum.at(data, key, :none) do
          :none -> {data, keys}
          val -> get_path(val, rst)
        end

      true ->
        {data, keys}
    end
  end

  def get_metadata_type(exception) do
    case get_path(exception, ["mechanism", "synthetic"]) do
      {value, []} -> String.slice(value, 0..128)
      _ -> "Error"
    end
  end

  def get_metadata(data) do
    paths = [
      ["logentry", "formatted"],
      ["logentry", "message"],
      ["message", "formatted"],
      ["message"]
    ]

    message = Enum.find(paths, fn path -> get_path(data, path) |> elem(1) |> length == 0 end)

    title =
      if is_binary(message) and String.valid?(message) do
        message
        |> String.trim()
        |> String.split("\n")
        |> Enum.at(0)
        |> String.slice(0..100)
      else
        "<unlabeled event>"
      end

    %{"title" => title}
  end

  defp get_last_exception(data) do
    [
      get_path(data, ["exception", "values", -1]),
      get_path(data, ["exception", -1])
    ]
    |> Enum.find(
      nil,
      fn {_last_exception, rst} -> length(rst) == 0 end
    )
  end

  def get_error_event_metadata(data) do
    exceptions = Map.get(data, "exceptions", [])

    if is_list(exceptions) and length(exceptions) == 0 do
      %{}
    else
      last_exception = get_last_exception(data)

      value =
        case last_exception do
          nil -> %{}
          last_exception -> Map.get(last_exception, "value", "")
        end

      %{
        "key" => get_metadata_type(last_exception),
        "value" => value
      }
    end

    # TODO - get "filename" and "function"
  end

  def get_title(metadata) do
    type = Map.get(metadata, "type", Map.get(metadata, "function", "<unknown>"))
    value = Map.get(metadata, "value")

    case value do
      nil ->
        type

      _ ->
        trunc_val =
          value
          |> String.split("\n")
          |> Enum.at(0)
          |> String.slice(0..128)

        "#{type}: #{trunc_val}"
    end
  end

  @max_search_part_length 250
  @max_vector_string_segment_len 2048
  def get_search_vector_uri_part(event) do
    case get_path(event, ["request", "url"]) do
      {url, []} ->
        parsed_url = URI.parse(url)

        truncated_path =
          String.slice(parsed_url.path, 0..@max_search_part_length)

        String.slice(
          "#{parsed_url.scheme}://#{parsed_url.host}#{truncated_path}",
          0..@max_search_part_length
        )

      _ ->
        nil
    end
  end

  @doc """
  Get string for search vector. The string must be short to ensure
  performance.
  """
  def get_search_vector(event, title, transaction) do
    [
      title && String.slice(title, 0..@max_search_part_length),
      transaction && String.slice(transaction, 0..@max_search_part_length),
      get_search_vector_uri_part(event)
      # TODO - Add stacktrace filenames
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
    |> then(fn search_vec ->
      if String.length(search_vec) <= @max_vector_string_segment_len do
        search_vec
      else
        search_vec
        |> String.split(" ")
        |> Enum.reduce(
          {[], 0},
          fn word, {words, str_length} ->
            if str_length + String.length(word) < @max_vector_string_segment_len do
              {[word | words], str_length + String.length(word)}
            else
              {words, str_length}
            end
          end
        )
        |> elem(0)
        |> Enum.reverse()
        |> Enum.join(" ")
      end
    end)
  end
end

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
end

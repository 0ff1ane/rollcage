defmodule ApiServer.Events.JavascriptEvents do
  alias ApiServer.Events.CommonUtils

  def get_stack_frames(payload) do
    exceptions = get_in(payload, ["exception", "values"])

    if not is_list(exceptions) do
      []
    else
      exceptions
      |> Enum.map(fn ex -> Map.get(ex, "stacktrace") end)
      |> Enum.reject(&is_nil/1)
      |> Enum.flat_map(fn ex -> Map.get(ex, "frames") end)
      |> Enum.reject(fn frame -> is_nil(frame) or is_nil(Map.get(frame, "lineno")) end)
    end
  end

  def parse(payload) do
    transaction = Map.get(payload, "transaction", "test_transaction")
    contexts = CommonUtils.parse_contexts(payload)
    tags = CommonUtils.parse_tags(payload, contexts)
    # TODO - for now assume error types. CSP types not supported yet
    metadata = CommonUtils.get_error_event_metadata(payload)
    title = CommonUtils.get_title(metadata)
    search_vector = CommonUtils.get_search_vector(payload, title, transaction)

    %{
      "title" => title,
      "search_vector" => search_vector,
      "metadata" => metadata,
      "contexts" => contexts,
      "tags" => tags,
      "stackframes" => get_stack_frames(payload),
      # payload,
      "payload" => %{},

      # TODO - fields below need to be parsed
      "transaction" => transaction,
      "timestamp" => DateTime.utc_now(),
      "event_id" => Ecto.UUID.generate(),
      "release" => "release",
      "event_type" => "error",
      "level" => "error"
    }
  end
end

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
    contexts = CommonUtils.parse_contexts(payload)
    tags = CommonUtils.parse_tags(payload, contexts)

    %{
      "payload" => payload,
      "contexts" => contexts,
      "tags" => tags,
      "stackframes" => get_stack_frames(payload)
    }
  end
end

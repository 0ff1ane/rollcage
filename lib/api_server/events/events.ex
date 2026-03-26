defmodule ApiServer.Events do
  alias ApiServer.Events.JavascriptEvents

  defp get_sdk_name(payload) do
    get_in(payload, ["sdk", "name"])
  end

  def parse_events("sentry.javascript.browser", payload) do
    JavascriptEvents.parse(payload)
  end

  def parse_events(_unsupported, payload) do
    %{"payload" => payload}
  end

  def parse(payload) do
    sdk_name = get_sdk_name(payload)
    parse_events(sdk_name, payload)
  end
end

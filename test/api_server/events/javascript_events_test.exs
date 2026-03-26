defmodule ApiServer.JavascriptEventsTest do
  use ApiServer.DataCase

  alias ApiServer.Events

  describe "javascript_events" do
    test "js_error_with_context.json is parsed correctly" do
      file_path =
        Path.expand(
          "#{__DIR__}/../../support/fixtures/data/incoming_events/js_error_with_context.json"
        )

      event = file_path |> File.read!() |> JSON.decode!()

      %{
        "payload" => payload,
        "contexts" => contexts,
        "tags" => tags,
        "stackframes" => stackframes
      } = Events.parse(event)

      assert %{"os" => %{"name" => "Ubuntu"}} = contexts
      assert %{"os" => %{"os.name" => "Ubuntu"}} = tags

      assert [
               %{
                 "colno" => 31,
                 "filename" => "http://localhost:4201/polyfills.js",
                 "function" => "globalZoneAwareCallback",
                 "in_app" => true,
                 "lineno" => 1660
               }
             ] = stackframes

      assert get_in(payload, ["sdk", "name"]) == "sentry.javascript.browser"
    end
  end
end

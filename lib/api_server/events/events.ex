defmodule ApiServer.Events do
  import Ecto.Query, warn: false

  alias ApiServer.ChRepo
  alias ApiServer.Events.Event
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

  def list_events_for_project(project_id) do
    from(
      event in Event,
      where: event.project_id == ^project_id
    )
    |> ChRepo.all()
  end

  def insert_event(event, params) do
    %Event{}
    |> Event.create_changeset(Map.merge(event, params))
    |> ChRepo.insert()
  end
end

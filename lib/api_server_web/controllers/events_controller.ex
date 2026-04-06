defmodule ApiServerWeb.EventsController do
  use ApiServerWeb, :controller

  alias ApiServer.Projects
  alias ApiServer.Events

  action_fallback ApiServerWeb.FallbackController

  def handle_event(conn, event) do
    with path <- current_url(conn),
         {:ok, project} <- Projects.get_project_from_dsn(path),
         event <- Events.parse(event),
         {:ok, _added} <-
           Events.insert_event(event, %{
             "project_id" => project.id,
             "organization_id" => project.organization_id
           }) do
      conn |> put_status(200) |> text("ok")
    end
  end
end

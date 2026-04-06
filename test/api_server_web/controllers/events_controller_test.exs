defmodule ApiServerWeb.EventControllerTest do
  alias ApiServer.Projects
  use ApiServerWeb.ConnCase

  alias ApiServer.Events
  alias ApiServer.AccountsFixtures
  import ApiServer.ProjectsFixtures

  setup %{conn: conn} do
    {:ok, projadmin} =
      %{
        "name" => "project admin",
        "email" => "projadmin@gg.com",
        "password" => "userpassword",
        "password_confirm" => "userpassword"
      }
      |> ApiServer.Accounts.create_user()

    projadmin_token = Phoenix.Token.sign(ApiServerWeb.Endpoint, "userauth", projadmin.id)

    projadmin_id = projadmin.id
    org = AccountsFixtures.organization_fixture(%{}, [projadmin_id])

    project =
      project_fixture(%{organization_id: org.id, created_by_id: projadmin.id}, [projadmin_id])

    {:ok,
     projadmin: projadmin,
     project: project,
     conn:
       conn
       |> put_req_header("accept", "application/json")
       |> put_req_header("authorization", projadmin_token)}
  end

  describe "handle event" do
    test "parses and saves event when payload is correct", %{
      conn: conn,
      projadmin: projadmin,
      project: project
    } do
      System.put_env("DSN_URL", "http://localhost:4000/dsn_at")
      System.put_env("DSN_PUBLIC_KEY_HEX", "1231982379aaf33")
      projadmin_id = projadmin.id

      file_path =
        Path.expand(
          "#{__DIR__}/../../support/fixtures/data/incoming_events/js_error_with_context.json"
        )

      event_data = file_path |> File.read!() |> JSON.decode!()
      event = Events.parse(event_data)

      {:ok, _added} =
        Events.insert_event(event, %{
          "project_id" => project.id,
          "organization_id" => project.organization_id
        })

      events = Events.list_events_for_project(project.id)
      assert length(events) == 1

      project_id_hex = project.id |> String.replace("-", "")
      conn = post(conn, ~p"/api/dsn/#{project_id_hex}", event: event)

      events = Events.list_events_for_project(project.id)
      assert length(events) == 1
    end
  end
end

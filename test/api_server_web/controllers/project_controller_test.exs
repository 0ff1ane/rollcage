defmodule ApiServerWeb.ProjectControllerTest do
  use ApiServerWeb.ConnCase

  import ApiServer.ProjectsFixtures
  alias ApiServer.AccountsFixtures

  @create_attrs %{
    name: "some name",
    desc: "some desc",
    image: "some image",
    dsn: "some dsn",
    admin_ids: [],
    member_ids: [],
    settings: %{}
  }
  @update_attrs %{
    name: "some updated name",
    desc: "some updated desc",
    image: "some updated image",
    dsn: "some updated dsn",
    member_ids: [],
    settings: %{}
  }
  @invalid_attrs %{
    name: nil,
    desc: nil,
    image: nil,
    dsn: nil,
    admin_ids: nil,
    member_ids: nil,
    settings: nil
  }

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

    {:ok, otheruser} =
      %{
        "name" => "other user",
        "email" => "user@gg.com",
        "password" => "userpassword",
        "password_confirm" => "userpassword"
      }
      |> ApiServer.Accounts.create_user()

    {:ok,
     projadmin: projadmin,
     otheruser: otheruser,
     conn:
       conn
       |> put_req_header("accept", "application/json")
       |> put_req_header("authorization", projadmin_token)}
  end

  describe "index" do
    test "lists all projects", %{conn: conn} do
      conn = get(conn, ~p"/api/projects")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create project" do
    test "renders project when data is valid", %{conn: conn, projadmin: projadmin} do
      projadmin_id = projadmin.id
      org = AccountsFixtures.organization_fixture(%{}, [projadmin_id])

      project_params =
        Map.merge(@create_attrs, %{organization_id: org.id, created_by_id: projadmin.id})

      conn = post(conn, ~p"/api/projects", project: project_params)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/projects/#{id}")

      assert %{
               "id" => ^id,
               "admin_ids" => [^projadmin_id],
               "desc" => "some desc",
               "member_ids" => [],
               "name" => "some name",
               "settings" => %{}
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, projadmin: projadmin} do
      projadmin_id = projadmin.id
      org = AccountsFixtures.organization_fixture(%{}, [projadmin_id])

      project_params =
        Map.merge(@invalid_attrs, %{organization_id: org.id, created_by_id: projadmin.id})

      conn = post(conn, ~p"/api/projects", project: project_params)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update project" do
    test "renders project when data is valid", %{conn: conn, projadmin: projadmin} do
      projadmin_id = projadmin.id
      org = AccountsFixtures.organization_fixture(%{}, [projadmin_id])

      project =
        project_fixture(%{organization_id: org.id, created_by_id: projadmin.id}, [projadmin_id])

      project_id = project.id

      conn = put(conn, ~p"/api/projects/#{project}", project: @update_attrs)
      assert %{"id" => ^project_id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/projects/#{project_id}")

      assert %{
               "id" => ^project_id,
               "admin_ids" => [^projadmin_id],
               "desc" => "some updated desc",
               "member_ids" => [],
               "name" => "some updated name",
               "settings" => %{}
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, projadmin: projadmin} do
      projadmin_id = projadmin.id
      org = AccountsFixtures.organization_fixture(%{}, [projadmin_id])

      project =
        project_fixture(%{organization_id: org.id, created_by_id: projadmin.id}, [projadmin_id])

      conn = put(conn, ~p"/api/projects/#{project}", project: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end
end

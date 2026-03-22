defmodule ApiServerWeb.OrganizationControllerTest do
  use ApiServerWeb.ConnCase

  import ApiServer.AccountsFixtures
  alias ApiServer.Accounts.Organization

  @create_attrs %{
    name: "some name",
    desc: "some desc",
    admin_ids: [],
    member_ids: []
  }
  @update_attrs %{
    name: "some updated name",
    desc: "some updated desc",
    member_ids: []
  }
  @invalid_attrs %{name: nil, desc: nil, admin_ids: nil, member_ids: nil}

  setup %{conn: conn} do
    {:ok, orgadmin} =
      %{
        "name" => "org admin",
        "email" => "orgadmin@gg.com",
        "password" => "userpassword",
        "password_confirm" => "userpassword"
      }
      |> ApiServer.Accounts.create_user()

    {:ok, otheruser} =
      %{
        "name" => "other user",
        "email" => "user@gg.com",
        "password" => "userpassword",
        "password_confirm" => "userpassword"
      }
      |> ApiServer.Accounts.create_user()

    orgadmin_token = Phoenix.Token.sign(ApiServerWeb.Endpoint, "userauth", orgadmin.id)

    {:ok,
     orgadmin: orgadmin,
     otheruser: otheruser,
     conn:
       conn
       |> put_req_header("accept", "application/json")
       |> put_req_header("authorization", orgadmin_token)}
  end

  describe "index" do
    test "lists all organizations", %{conn: conn} do
      conn = get(conn, ~p"/api/organizations")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create organization" do
    test "renders organization when data is valid", %{conn: conn, orgadmin: orgadmin} do
      conn = post(conn, ~p"/api/organizations", organization: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/organizations/#{id}")

      orgadmin_id = orgadmin.id

      assert %{
               "id" => ^id,
               # user must be auto-added as admin
               "admin_ids" => [^orgadmin_id],
               "desc" => "some desc",
               "member_ids" => [],
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/organizations", organization: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update organization" do
    test "renders organization when data is valid", %{
      conn: conn,
      orgadmin: orgadmin
    } do
      orgadmin_id = orgadmin.id
      organization = organization_fixture(%{}, [orgadmin.id])
      organization_id = organization.id

      conn = put(conn, ~p"/api/organizations/#{organization}", organization: @update_attrs)
      assert %{"id" => ^organization_id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/organizations/#{organization_id}")

      assert %{
               "id" => ^organization_id,
               "admin_ids" => [^orgadmin_id],
               "desc" => "some updated desc",
               "member_ids" => [],
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, orgadmin: orgadmin} do
      organization = organization_fixture(%{}, [orgadmin.id])
      organization_id = organization.id

      conn = put(conn, ~p"/api/organizations/#{organization}", organization: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  defp create_organization(_) do
    organization = organization_fixture()

    %{organization: organization}
  end
end

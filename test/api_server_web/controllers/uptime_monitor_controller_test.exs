defmodule ApiServerWeb.UptimeMonitorControllerTest do
  use ApiServerWeb.ConnCase

  import ApiServer.UptimeFixtures
  alias ApiServer.AccountsFixtures

  @create_attrs %{
    name: "my uptime monitor",
    desc: "description for my uptime monitor",
    admin_ids: [],
    member_ids: [],
    target_url: "some target_url",
    period_secs: 42
  }
  @update_attrs %{
    member_ids: [],
    target_url: "some updated target_url",
    period_secs: 43
  }
  @invalid_attrs %{admin_ids: nil, member_ids: nil, target_url: nil, period_secs: nil}

  setup %{conn: conn} do
    {:ok, admin} =
      %{
        "name" => "admin",
        "email" => "admin@gg.com",
        "password" => "userpassword",
        "password_confirm" => "userpassword"
      }
      |> ApiServer.Accounts.create_user()

    admin_token = Phoenix.Token.sign(ApiServerWeb.Endpoint, "userauth", admin.id)

    {:ok,
     admin: admin,
     conn:
       conn
       |> put_req_header("accept", "application/json")
       |> put_req_header("authorization", admin_token)}
  end

  describe "index" do
    test "lists all uptime_monitors", %{conn: conn} do
      conn = get(conn, ~p"/api/uptime_monitors")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create uptime_monitor" do
    test "renders uptime_monitor when data is valid", %{conn: conn, admin: admin} do
      admin_id = admin.id
      organization = AccountsFixtures.organization_fixture(%{}, [admin.id])

      params =
        Map.merge(@create_attrs, %{
          organization_id: organization.id,
          created_by_id: admin.id
        })

      conn = post(conn, ~p"/api/uptime_monitors", uptime_monitor: params)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/uptime_monitors/#{id}")

      assert %{
               "id" => ^id,
               "admin_ids" => [^admin_id],
               "member_ids" => [],
               "period_secs" => 42,
               "target_url" => "some target_url"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, admin: admin} do
      organization = AccountsFixtures.organization_fixture(%{}, [admin.id])

      params =
        Map.merge(@invalid_attrs, %{
          organization_id: organization.id,
          created_by_id: admin.id
        })

      conn = post(conn, ~p"/api/uptime_monitors", uptime_monitor: params)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update uptime_monitor" do
    test "renders uptime_monitor when data is valid", %{
      conn: conn,
      admin: admin
    } do
      admin_id = admin.id
      uptime_monitor = create_uptime_monitor(admin.id)
      uptime_monitor_id = uptime_monitor.id
      conn = put(conn, ~p"/api/uptime_monitors/#{uptime_monitor}", uptime_monitor: @update_attrs)
      assert %{"id" => ^uptime_monitor_id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/uptime_monitors/#{uptime_monitor_id}")

      assert %{
               "id" => ^uptime_monitor_id,
               "admin_ids" => [^admin_id],
               "created_by_id" => ^admin_id,
               "member_ids" => [],
               "period_secs" => 43,
               "target_url" => "some updated target_url"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, admin: admin} do
      uptime_monitor = create_uptime_monitor(admin.id)
      conn = put(conn, ~p"/api/uptime_monitors/#{uptime_monitor}", uptime_monitor: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  defp create_uptime_monitor(user_id) do
    organization = AccountsFixtures.organization_fixture(%{}, [user_id])

    uptime_monitor_fixture(
      %{
        organization_id: organization.id
      },
      [user_id],
      user_id
    )
  end
end

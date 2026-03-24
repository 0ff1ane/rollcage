defmodule ApiServer.UptimeTest do
  alias ApiServer.AccountsFixtures
  use ApiServer.DataCase

  alias ApiServer.Uptime
  import ApiServer.UptimeFixtures

  describe "uptime_monitors" do
    alias ApiServer.Uptime.UptimeMonitor

    @invalid_attrs %{admin_ids: nil, member_ids: nil, target_url: nil, period_secs: nil}

    test "list_uptime_monitors/0 returns all uptime_monitors" do
      uptime_monitor = create_uptime_monitor()
      assert Uptime.list_uptime_monitors(uptime_monitor.created_by_id) == [uptime_monitor]
    end

    test "get_uptime_monitor!/1 returns the uptime_monitor with given id" do
      uptime_monitor = create_uptime_monitor()
      assert Uptime.get_uptime_monitor!(uptime_monitor.id) == uptime_monitor
    end

    test "create_uptime_monitor/1 with valid data creates a uptime_monitor" do
      user = AccountsFixtures.user_fixture(%{})
      organization = AccountsFixtures.organization_fixture(%{}, [user.id])

      valid_attrs = %{
        name: "my uptime monitor",
        desc: "description for my uptime monitor",
        period_secs: 42,
        target_url: "some target_url",
        organization_id: organization.id,
        created_by_id: user.id,
        admin_ids: [user.id],
        member_ids: []
      }

      assert {:ok, %UptimeMonitor{} = uptime_monitor} = Uptime.create_uptime_monitor(valid_attrs)
      assert uptime_monitor.organization_id == organization.id
      assert uptime_monitor.admin_ids == [user.id]
      assert uptime_monitor.member_ids == []
      assert uptime_monitor.target_url == "some target_url"
      assert uptime_monitor.period_secs == 42
      assert uptime_monitor.name == "my uptime monitor"
      assert uptime_monitor.desc == "description for my uptime monitor"
    end

    test "create_uptime_monitor/1 with invalid data returns error changeset" do
      user = AccountsFixtures.user_fixture(%{})

      params =
        Map.merge(@invalid_attrs, %{
          created_by_id: user.id,
          admin_ids: [user.id]
        })

      assert {:error, %Ecto.Changeset{}} = Uptime.create_uptime_monitor(params)
    end

    test "update_uptime_monitor/2 with valid data updates the uptime_monitor" do
      uptime_monitor = create_uptime_monitor()

      update_attrs = %{
        member_ids: [],
        target_url: "some updated target_url",
        period_secs: 43
      }

      assert {:ok, %UptimeMonitor{} = uptime_monitor} =
               Uptime.update_uptime_monitor(uptime_monitor, update_attrs)

      assert [_admin_id] = uptime_monitor.admin_ids
      assert uptime_monitor.member_ids == []
      assert uptime_monitor.target_url == "some updated target_url"
      assert uptime_monitor.period_secs == 43
    end

    test "update_uptime_monitor/2 with invalid data returns error changeset" do
      uptime_monitor = create_uptime_monitor()

      assert {:error, %Ecto.Changeset{}} =
               Uptime.update_uptime_monitor(uptime_monitor, @invalid_attrs)

      assert uptime_monitor == Uptime.get_uptime_monitor!(uptime_monitor.id)
    end

    test "change_uptime_monitor/1 returns a uptime_monitor changeset" do
      uptime_monitor = create_uptime_monitor()
      assert %Ecto.Changeset{} = Uptime.change_uptime_monitor(uptime_monitor)
    end
  end

  defp create_uptime_monitor() do
    user = AccountsFixtures.user_fixture(%{})
    organization = AccountsFixtures.organization_fixture(%{}, [user.id])

    uptime_monitor_fixture(
      %{
        organization_id: organization.id
      },
      [user.id],
      user.id
    )
  end
end

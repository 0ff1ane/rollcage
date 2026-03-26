defmodule ApiServer.UptimeFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ApiServer.Uptime` context.
  """

  @doc """
  Generate a uptime_monitor.
  """
  def uptime_monitor_fixture(attrs \\ %{}, admin_ids \\ [], created_by_id \\ nil) do
    {:ok, uptime_monitor} =
      attrs
      |> Enum.into(%{
        name: "test uptime monitor",
        desc: "description for test uptime monitor",
        target_url: "some target_url",
        period_secs: 42,
        created_by_id: created_by_id,
        admin_ids: admin_ids,
        member_ids: []
      })
      |> ApiServer.Uptime.create_uptime_monitor()

    uptime_monitor
  end
end

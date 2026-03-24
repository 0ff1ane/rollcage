defmodule ApiServerWeb.UptimeMonitorJSON do
  alias ApiServer.Uptime.UptimeMonitor

  @doc """
  Renders a list of uptime_monitors.
  """
  def index(%{uptime_monitors: uptime_monitors}) do
    %{data: for(uptime_monitor <- uptime_monitors, do: data(uptime_monitor))}
  end

  @doc """
  Renders a single uptime_monitor.
  """
  def show(%{uptime_monitor: uptime_monitor}) do
    %{data: data(uptime_monitor)}
  end

  defp data(%UptimeMonitor{} = uptime_monitor) do
    %{
      id: uptime_monitor.id,
      created_by_id: uptime_monitor.created_by_id,
      organization_id: uptime_monitor.organization_id,
      admin_ids: uptime_monitor.admin_ids,
      member_ids: uptime_monitor.member_ids,
      target_url: uptime_monitor.target_url,
      period_secs: uptime_monitor.period_secs
    }
  end
end

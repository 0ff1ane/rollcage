defmodule ApiServer.Uptime.UptimeManager do
  use GenServer

  alias ApiServer.Uptime
  alias ApiServer.Uptime.UptimeSupervisor

  @period 10_000

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    schedule_periodic_update()
    {:ok, []}
  end

  def handle_info(:update_uptime_monitors, state) do
    monitor_configs = Uptime.list_all_uptime_monitors()
    UptimeSupervisor.update_monitors(monitor_configs)

    schedule_periodic_update()
    {:noreply, state}
  end

  def handle_info({:update_monitor, config}, state) do
    UptimeSupervisor.update_monitor(config)
    {:noreply, state}
  end

  def update_monitor(config) do
    send(__MODULE__, {:update_monitor, config})
  end

  defp schedule_periodic_update, do: Process.send_after(self(), :update_uptime_monitors, @period)
end

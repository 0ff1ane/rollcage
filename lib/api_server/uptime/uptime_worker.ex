defmodule ApiServer.Uptime.UptimeWorker do
  # TODO - need to decide if to keep this transient
  use GenServer, restart: :transient

  require Logger

  def init(state) do
    period_secs = Map.fetch!(state, :period_secs)
    schedule_update(period_secs)
    {:ok, state}
  end

  def handle_info(:check_target, state) do
    worker_name = Map.fetch!(state, :id)
    is_active = Map.fetch!(state, :is_active)
    target_url = Map.fetch!(state, :target_url)
    period_secs = Map.fetch!(state, :period_secs)

    if is_active do
      # TODO - call HTTPoison.get on target_url with reasonably long timeout
      Logger.info(
        "--- TODO : from worker_name=#{worker_name} :: checking target_url=#{target_url}"
      )
    else
      # TODO - decide if to call GenServer.stop(self()) here or allow Supervisor to handle?
      Logger.info(
        "--- INACTIVE_MONITOR : from worker_name=#{worker_name} :: target_url=#{target_url}"
      )
    end

    schedule_update(period_secs)
    {:noreply, state}
  end

  def handle_call({:update_config, new_state}, _from, _state) do
    {:reply, :ok, new_state}
  end

  def handle_call(:stop, _from, state) do
    {:stop, :shutdown, state, state}
  end

  def update(worker_pid, config) do
    GenServer.call(worker_pid, {:update_config, config})
  end

  def stop(worker_pid) do
    GenServer.stop(worker_pid, :shutdown)
  end

  defp schedule_update(time_secs) do
    Process.send_after(self(), :check_target, time_secs * 1_000)
  end
end

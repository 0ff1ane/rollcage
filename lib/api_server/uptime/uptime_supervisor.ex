defmodule ApiServer.Uptime.UptimeSupervisor do
  alias ApiServer.Uptime.UptimeWorker
  use DynamicSupervisor

  def start_link(args) do
    DynamicSupervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    DynamicSupervisor.init(max_children: 1000)
  end

  def add_monitor(uptime_config) do
    add_monitors([uptime_config])
  end

  def update_monitor(uptime_config) do
    update_existing_monitors([uptime_config])
  end

  def update_monitors(uptime_configs) do
    # update running monitors
    updated_configs = update_existing_monitors(uptime_configs)

    # stop children which are not in updated_configs
    stop_configs = uptime_configs -- updated_configs

    stopped_monitor_count =
      __MODULE__
      |> DynamicSupervisor.which_children()
      |> get_valid_children()
      |> stop_monitors(stop_configs)

    # add new uptime monitors
    new_configs = uptime_configs -- updated_configs
    added_monitor_count = add_monitors(new_configs)

    %{
      added: added_monitor_count,
      updated: length(updated_configs),
      stopped: stopped_monitor_count
    }
  end

  defp add_monitors(uptime_configs) do
    uptime_configs
    |> Enum.filter(fn monitor_config ->
      child_name = make_child_name(monitor_config.id)
      worker_name = get_worker_name(child_name)

      DynamicSupervisor.start_child(
        __MODULE__,
        %{
          id: nil,
          start:
            {GenServer, :start_link,
             [
               UptimeWorker,
               Map.merge(monitor_config, %{worker_name: worker_name}),
               [name: worker_name]
             ]},
          restart: :transient
        }
      )
      |> case do
        {:ok, _} -> true
        {:ok, _, _} -> true
        _ -> false
      end
    end)
    |> length
  end

  defp update_existing_monitors(uptime_configs) do
    uptime_configs
    # monitors with is_active=false should be removed in stop_monitors() after this
    |> Enum.filter(&(&1.is_active == true))
    |> Enum.filter(fn monitor_config ->
      child_name = make_child_name(monitor_config.id)
      pid = get_pid_from_worker_name(child_name)

      if is_nil(pid) do
        false
      else
        UptimeWorker.update(pid, monitor_config)
        true
      end
    end)
  end

  defp stop_monitors(child_monitors, stop_configs) do
    pids_for_stop_configs =
      stop_configs
      |> Enum.map(fn monitor_config ->
        monitor_config.id |> make_child_name() |> get_pid_from_worker_name()
      end)
      |> Enum.reject(&is_nil/1)

    child_monitors
    |> Enum.filter(fn child_monitor ->
      {_module, child_monitor_pid, _worker, [_type]} = child_monitor

      if child_monitor_pid in pids_for_stop_configs do
        DynamicSupervisor.terminate_child(__MODULE__, child_monitor_pid)
        true
      else
        false
      end
    end)
    |> length()
  end

  defp get_valid_children(child_monitors) do
    child_monitors
    |> Enum.filter(fn {_module, child_monitor_pid, _type, [_child_monitor_name]} ->
      is_pid(child_monitor_pid)
    end)
  end

  defp make_child_name(id), do: "uptime_monitor_#{id}"

  defp get_worker_name(name), do: {:via, Registry, {:uptime_monitors_registry, name}}

  defp get_pid_from_worker_name(worker_name) do
    :uptime_monitors_registry
    |> Registry.lookup(worker_name)
    |> case do
      [{pid, _} | _] when is_pid(pid) -> pid
      _ -> nil
    end
  end
end

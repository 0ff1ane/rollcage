defmodule ApiServerWeb.UptimeMonitorController do
  use ApiServerWeb, :controller

  alias ApiServer.Accounts
  alias ApiServer.Uptime
  alias ApiServer.Uptime.UptimeMonitor

  action_fallback ApiServerWeb.FallbackController

  def index(conn, _params) do
    with current_user <- conn.assigns.current_user,
         uptime_monitors <- Uptime.list_uptime_monitors(current_user.id) do
      render(conn, :index, uptime_monitors: uptime_monitors)
    end
  end

  defp make_params_with_default_admin_id(params, admin_id) do
    Map.merge(params, %{"admin_ids" => [admin_id], "created_by_id" => admin_id})
  end

  defp get_org_id_from_params(params) do
    params
    |> Map.get("organization_id")
    |> case do
      nil -> {:error, :not_found}
      org_id -> {:ok, org_id}
    end
  end

  def create(conn, %{"uptime_monitor" => uptime_monitor_params}) do
    with current_user <- conn.assigns.current_user,
         {:ok, org_id} <- get_org_id_from_params(uptime_monitor_params),
         true <- Accounts.is_user_org_admin(current_user.id, org_id),
         params <- make_params_with_default_admin_id(uptime_monitor_params, current_user.id),
         {:ok, %UptimeMonitor{} = uptime_monitor} <-
           Uptime.create_uptime_monitor(params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/uptime_monitors/#{uptime_monitor}")
      |> render(:show, uptime_monitor: uptime_monitor)
    end
  end

  def show(conn, %{"id" => id}) do
    with current_user <- conn.assigns.current_user,
         {:ok, uptime_monitor} <- Uptime.get_uptime_monitor(id, current_user.id) do
      render(conn, :show, uptime_monitor: uptime_monitor)
    end
  end

  def update(conn, %{"id" => id, "uptime_monitor" => uptime_monitor_params}) do
    with current_user <- conn.assigns.current_user,
         {:ok, uptime_monitor} <- Uptime.get_uptime_monitor_as_admin(id, current_user.id),
         {:ok, %UptimeMonitor{} = uptime_monitor} <-
           Uptime.update_uptime_monitor(uptime_monitor, uptime_monitor_params) do
      render(conn, :show, uptime_monitor: uptime_monitor)
    end
  end
end

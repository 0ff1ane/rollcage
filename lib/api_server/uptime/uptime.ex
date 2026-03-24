defmodule ApiServer.Uptime do
  @moduledoc """
  The Uptime context.
  """

  import Ecto.Query, warn: false

  alias ApiServer.Repo
  alias ApiServer.Uptime.UptimeMonitor
  alias ApiServer.Uptime.UptimeManager

  def list_all_uptime_monitors do
    Repo.all(UptimeMonitor)
  end

  def list_uptime_monitors(user_id) do
    from(
      upmon in UptimeMonitor,
      where: ^user_id in upmon.admin_ids or ^user_id in upmon.member_ids
    )
    |> Repo.all()
  end

  def get_uptime_monitor!(id), do: Repo.get!(UptimeMonitor, id)

  def get_uptime_monitor_as_admin(id, user_id) do
    from(
      upmon in UptimeMonitor,
      where: upmon.id == ^id,
      where: ^user_id in upmon.admin_ids
    )
    |> Repo.one()
    |> case do
      nil -> {:error, :not_found}
      upmon -> {:ok, upmon}
    end
  end

  def get_uptime_monitor(id, user_id) do
    from(
      upmon in UptimeMonitor,
      where: upmon.id == ^id,
      where: ^user_id in upmon.admin_ids or ^user_id in upmon.member_ids
    )
    |> Repo.one()
    |> case do
      nil -> {:error, :not_found}
      upmon -> {:ok, upmon}
    end
  end

  def create_uptime_monitor(attrs) do
    %UptimeMonitor{}
    |> UptimeMonitor.create_changeset(attrs)
    |> Repo.insert()
  end

  def update_uptime_monitor(%UptimeMonitor{} = uptime_monitor, attrs) do
    uptime_monitor
    |> UptimeMonitor.update_changeset(attrs)
    |> Repo.update()
    |> tap(fn uptime_monitor ->
      UptimeManager.update_monitor(uptime_monitor)
    end)
  end

  def change_uptime_monitor(%UptimeMonitor{} = uptime_monitor, attrs \\ %{}) do
    UptimeMonitor.create_changeset(uptime_monitor, attrs)
  end
end

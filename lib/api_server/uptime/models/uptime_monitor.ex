defmodule ApiServer.Uptime.UptimeMonitor do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "uptime_monitors" do
    field :name, :string
    field :desc, :string
    field :is_active, :boolean, default: true
    field :admin_ids, {:array, :binary_id}
    field :member_ids, {:array, :binary_id}
    field :target_url, :string
    field :period_secs, :integer
    field :created_by_id, :binary_id
    field :organization_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def create_changeset(uptime_monitor, attrs) do
    uptime_monitor
    |> cast(attrs, [
      :name,
      :desc,
      :is_active,
      :admin_ids,
      :member_ids,
      :target_url,
      :period_secs,
      :created_by_id,
      :organization_id
    ])
    |> validate_required([
      :name,
      :desc,
      :admin_ids,
      :member_ids,
      :target_url,
      :period_secs,
      :created_by_id,
      :organization_id
    ])
    |> validate_length(:name, min: 5, max: 30)
    |> validate_admin_ids()
  end

  @doc false
  def update_changeset(uptime_monitor, attrs) do
    uptime_monitor
    |> cast(attrs, [
      :is_active,
      :admin_ids,
      :member_ids,
      :target_url,
      :period_secs
    ])
    |> validate_required([
      :name,
      :desc,
      :admin_ids,
      :member_ids,
      :target_url,
      :period_secs
    ])
    |> validate_length(:name, min: 5, max: 30)
    |> validate_admin_ids()
  end

  defp validate_admin_ids(changeset) do
    validate_change(changeset, :admin_ids, fn _field, admin_ids ->
      # TODO - make sure admin_ids exists in users table!
      if length(admin_ids) < 1 do
        [{:admin_ids, "must have at least one admin"}]
      else
        []
      end
    end)
  end
end

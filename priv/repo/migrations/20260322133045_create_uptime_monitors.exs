defmodule ApiServer.Repo.Migrations.CreateUptimeMonitors do
  use Ecto.Migration

  def change do
    create table(:uptime_monitors, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :desc, :string
      add :is_active, :boolean, default: true, null: false
      add :admin_ids, {:array, :binary_id}
      add :member_ids, {:array, :binary_id}
      add :target_url, :string, null: false
      add :period_secs, :integer, null: false
      add :created_by_id, references(:users, on_delete: :nothing, type: :binary_id), null: false

      add :organization_id, references(:organizations, on_delete: :nothing, type: :binary_id),
        null: false

      timestamps(type: :utc_datetime)
    end

    create index(:uptime_monitors, [:organization_id, :is_active])
  end
end

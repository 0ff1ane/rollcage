defmodule ApiServer.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :desc, :string
      add :image, :string
      add :admin_ids, {:array, :binary_id}
      add :member_ids, {:array, :binary_id}
      add :settings, :map
      add :created_by_id, references(:users, on_delete: :nothing, type: :binary_id), null: false

      add :organization_id, references(:organizations, on_delete: :nothing, type: :binary_id),
        null: false

      timestamps(type: :utc_datetime)
    end

    create index(:projects, [:organization_id])
  end
end

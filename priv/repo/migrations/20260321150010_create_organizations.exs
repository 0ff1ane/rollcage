defmodule ApiServer.Repo.Migrations.CreateOrganizations do
  use Ecto.Migration

  def change do
    create table(:organizations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :desc, :string
      add :admin_ids, {:array, :binary_id}
      add :member_ids, {:array, :binary_id}

      timestamps(type: :utc_datetime)
    end
  end
end

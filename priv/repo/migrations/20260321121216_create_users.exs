defmodule ApiServer.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def up do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :email, :string, null: false
      add :password_hash, :string, null: false
      add :profile_image, :string
      add :is_activated, :boolean, null: false
      add :is_enabled, :boolean, default: true

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:email])
  end

  def down do
    drop unique_index(:users, [:email])
    drop table(:users)
  end
end

defmodule ApiServer.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "projects" do
    field :name, :string
    field :desc, :string
    field :image, :string
    field :admin_ids, {:array, :binary_id}
    field :member_ids, {:array, :binary_id}
    field :settings, :map
    field :created_by_id, :binary_id
    field :organization_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def create_changeset(project, attrs) do
    project
    |> cast(attrs, [
      :name,
      :desc,
      :image,
      :created_by_id,
      :organization_id,
      :admin_ids,
      :member_ids,
      :settings
    ])
    |> validate_required([
      :name,
      :desc,
      :image,
      :created_by_id,
      :organization_id,
      :admin_ids,
      :member_ids
    ])
    |> validate_length(:name, min: 5, max: 30)
    |> validate_admin_ids()
  end

  @doc false
  def update_changeset(project, attrs) do
    project
    |> cast(attrs, [
      :name,
      :desc,
      :image,
      :admin_ids,
      :member_ids,
      :settings
    ])
    |> validate_required([
      :name,
      :desc,
      :image,
      :admin_ids,
      :member_ids
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

defmodule ApiServer.Accounts.Organization do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "organizations" do
    field :name, :string
    field :desc, :string
    field :admin_ids, {:array, :binary_id}
    field :member_ids, {:array, :binary_id}

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(organization, attrs) do
    organization
    |> cast(attrs, [:name, :desc, :admin_ids, :member_ids])
    |> validate_required([:name, :desc, :admin_ids, :member_ids])
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

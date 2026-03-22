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
  end
end

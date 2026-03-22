defmodule ApiServer.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :name, :string
    field :email, :string
    field :password_hash, :string
    field :profile_image, :string
    field :is_activated, :boolean
    field :is_enabled, :boolean, default: true

    field :password, :string, virtual: true
    field :password_confirm, :string, virtual: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def create_changeset(user, attrs) do
    user
    |> cast(attrs, [
      :name,
      :email,
      :password,
      :password_confirm,
      :profile_image,
      :is_activated
    ])
    |> validate_required([
      :name,
      :email,
      :password,
      :password_confirm,
      :is_activated
    ])
    |> unique_constraint([:email])
    |> validate_passwords_match()
    |> hash_password()
  end

  @doc false
  def update_changeset(user, attrs) do
    user
    |> cast(attrs, [
      :name,
      :password,
      :password_confirm,
      :profile_image,
      :is_activated,
      :is_enabled
    ])
    |> validate_passwords_match()
    |> hash_password()
  end

  def validate_passwords_match(changeset) do
    password = get_field(changeset, :password)

    validate_change(changeset, :password_confirm, fn _field, password_confirm ->
      case password_confirm == password do
        true ->
          []

        false ->
          [{:password, "Passwords must match"}]
      end
    end)
  end

  def hash_password(changeset) do
    case get_field(changeset, :password) do
      nil ->
        changeset

      password ->
        log_rounds = if System.get_env("MIX_ENV") == "test", do: 2, else: 12
        password_hash = Bcrypt.hash_pwd_salt(password, log_rounds: log_rounds)

        changeset
        |> put_change(:password_hash, password_hash)
    end
  end
end

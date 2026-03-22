defmodule ApiServer.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias ApiServer.Repo

  alias ApiServer.Accounts.User
  alias ApiServer.Accounts.Organization

  def list_users do
    Repo.all(User)
  end

  def get_user!(id), do: Repo.get!(User, id)

  def create_user(attrs) do
    # TODO: we set is_activated to true till we have an email provider
    %User{is_activated: true}
    |> User.create_changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.update_changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def change_user(%User{} = user, attrs \\ %{}) do
    User.update_changeset(user, attrs)
  end

  def list_organizations(user_id) do
    from(
      org in Organization,
      where: ^user_id in org.admin_ids or ^user_id in org.member_ids
    )
    |> Repo.all()
  end

  def get_organization!(id), do: Repo.get!(Organization, id)

  def get_organization(id, user_id) do
    from(
      org in Organization,
      where: org.id == ^id,
      where: ^user_id in org.admin_ids or ^user_id in org.member_ids
    )
    |> Repo.one()
    |> case do
      nil -> :error
      org -> {:ok, org}
    end
  end

  def is_user_org_admin(user_id, org_id) do
    from(
      org in Organization,
      where: ^user_id in org.admin_ids,
      where: org.id == ^org_id
    )
    |> Repo.one()
    |> then(fn row -> not is_nil(row) end)
  end

  def create_organization(attrs) do
    %Organization{}
    |> Organization.changeset(attrs)
    |> Repo.insert()
  end

  def update_organization(%Organization{} = organization, attrs) do
    organization
    |> Organization.changeset(attrs)
    |> Repo.update()
  end

  def change_organization(%Organization{} = organization, attrs \\ %{}) do
    Organization.changeset(organization, attrs)
  end
end

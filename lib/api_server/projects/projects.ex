defmodule ApiServer.Projects do
  @moduledoc """
  The Projects context.
  """

  import Ecto.Query, warn: false
  alias ApiServer.Repo

  alias ApiServer.Projects.Project

  def list_projects(user_id) do
    from(
      proj in Project,
      where: ^user_id in proj.admin_ids or ^user_id in proj.member_ids
    )
    |> Repo.all()
  end

  def get_project!(id), do: Repo.get!(Project, id)

  defp base_get_query(id) do
    from(
      proj in Project,
      where: proj.id == ^id
    )
  end

  defp nillable_to_tuple(value) do
    value
    |> case do
      nil -> {:error, :not_found}
      proj -> {:ok, proj}
    end
  end

  def get_project_as_admin(id, user_id) do
    base_get_query(id)
    |> where([proj], ^user_id in proj.admin_ids)
    |> Repo.one()
    |> nillable_to_tuple()
  end

  def get_project(id, user_id) do
    base_get_query(id)
    |> where([proj], ^user_id in proj.admin_ids or ^user_id in proj.member_ids)
    |> Repo.one()
    |> nillable_to_tuple()
  end

  def is_user_project_admin(user_id, proj_id) do
    from(
      proj in Project,
      where: ^user_id in proj.admin_ids,
      where: proj.id == ^proj_id
    )
    |> Repo.one()
    |> then(fn row -> not is_nil(row) end)
  end

  def create_project(attrs) do
    %Project{}
    |> Project.create_changeset(attrs)
    |> Repo.insert()
  end

  def update_project(%Project{} = project, attrs) do
    project
    |> Project.update_changeset(attrs)
    |> Repo.update()
  end

  def change_project(%Project{} = project, attrs \\ %{}) do
    Project.create_changeset(project, attrs)
  end

  def get_dsn(nil) do
    {:error, :invalid_dsn}
  end

  def get_dsn(project_id) do
    _project = get_project!(project_id)
    dsn_url = System.get_env("DSN_URL")
    public_key_hex = System.get_env("DSN_PUBLIC_KEY_HEX")
    %{scheme: scheme, host: host, path: path} = URI.parse(dsn_url)
    project_id_hex = project_id |> String.replace("-", "")

    case String.length(project_id_hex) do
      32 ->
        {:ok, "#{scheme}://#{public_key_hex}@#{host}#{path}/#{project_id_hex}"}

      _ ->
        {:error, :invalid_dsn}
    end
  end
end

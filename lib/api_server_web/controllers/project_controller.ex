defmodule ApiServerWeb.ProjectController do
  use ApiServerWeb, :controller

  alias ApiServer.Accounts
  alias ApiServer.Projects
  alias ApiServer.Projects.Project

  action_fallback ApiServerWeb.FallbackController

  def index(conn, _params) do
    with current_user <- conn.assigns.current_user,
         projects <- Projects.list_projects(current_user.id) do
      render(conn, :index, projects: projects)
    end
  end

  defp make_params_with_default_admin_id(params, admin_id) do
    Map.merge(params, %{"admin_ids" => [admin_id], "created_by_id" => admin_id})
  end

  defp get_org_id_from_params(params) do
    params
    |> Map.get("organization_id")
    |> case do
      nil -> {:error, :not_found}
      org_id -> {:ok, org_id}
    end
  end

  def create(conn, %{"project" => project_params}) do
    with current_user <- conn.assigns.current_user,
         {:ok, org_id} <- get_org_id_from_params(project_params),
         true <- Accounts.is_user_org_admin(current_user.id, org_id),
         params <- make_params_with_default_admin_id(project_params, current_user.id),
         {:ok, %Project{} = project} <- Projects.create_project(params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/projects/#{project}")
      |> render(:show, project: project)
    end
  end

  def show(conn, %{"id" => id}) do
    with current_user <- conn.assigns.current_user,
         {:ok, project} <- Projects.get_project_for_user(id, current_user.id) do
      render(conn, :show, project: project)
    end
  end

  def update(conn, %{"id" => id, "project" => project_params}) do
    with current_user <- conn.assigns.current_user,
         {:ok, project} <- Projects.get_project_as_admin(id, current_user.id),
         {:ok, %Project{} = project} <- Projects.update_project(project, project_params) do
      render(conn, :show, project: project)
    end
  end
end

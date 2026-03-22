defmodule ApiServerWeb.OrganizationController do
  use ApiServerWeb, :controller

  alias ApiServer.Accounts
  alias ApiServer.Accounts.Organization

  action_fallback ApiServerWeb.FallbackController

  def index(conn, _params) do
    with current_user <- conn.assigns.current_user,
         organizations <- Accounts.list_organizations(current_user.id) do
      render(conn, :index, organizations: organizations)
    end
  end

  defp make_params_with_default_admin_id(params, admin_id) do
    Map.merge(params, %{"admin_ids" => [admin_id]})
  end

  def create(conn, %{"organization" => organization_params}) do
    with current_user <- conn.assigns.current_user,
         params <- make_params_with_default_admin_id(organization_params, current_user.id),
         {:ok, %Organization{} = organization} <-
           Accounts.create_organization(params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/organizations/#{organization}")
      |> render(:show, organization: organization)
    end
  end

  def show(conn, %{"id" => id}) do
    with current_user <- conn.assigns.current_user,
         {:ok, organization} <- Accounts.get_organization(id, current_user.id) do
      render(conn, :show, organization: organization)
    end
  end

  def update(conn, %{"id" => id, "organization" => organization_params}) do
    with current_user <- conn.assigns.current_user,
         true <- Accounts.is_user_org_admin(current_user.id, id),
         {:ok, organization} <- Accounts.get_organization(id, current_user.id),
         {:ok, %Organization{} = organization} <-
           Accounts.update_organization(organization, organization_params) do
      render(conn, :show, organization: organization)
    end
  end
end

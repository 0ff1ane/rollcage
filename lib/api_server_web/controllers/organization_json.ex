defmodule ApiServerWeb.OrganizationJSON do
  alias ApiServer.Accounts.Organization

  @doc """
  Renders a list of organizations.
  """
  def index(%{organizations: organizations}) do
    %{data: for(organization <- organizations, do: data(organization))}
  end

  @doc """
  Renders a single organization.
  """
  def show(%{organization: organization}) do
    %{data: data(organization)}
  end

  defp data(%Organization{} = organization) do
    %{
      id: organization.id,
      name: organization.name,
      desc: organization.desc,
      admin_ids: organization.admin_ids,
      member_ids: organization.member_ids
    }
  end
end

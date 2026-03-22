defmodule ApiServerWeb.ProjectJSON do
  alias ApiServer.Projects.Project

  @doc """
  Renders a list of projects.
  """
  def index(%{projects: projects}) do
    %{data: for(project <- projects, do: data(project))}
  end

  @doc """
  Renders a single project.
  """
  def show(%{project: project}) do
    %{data: data(project)}
  end

  defp data(%Project{} = project) do
    %{
      id: project.id,
      name: project.name,
      desc: project.desc,
      image: project.image,
      admin_ids: project.admin_ids,
      member_ids: project.member_ids,
      settings: project.settings
    }
  end
end

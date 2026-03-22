defmodule ApiServer.ProjectsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ApiServer.Projects` context.
  """

  @doc """
  Generate a project.
  """
  def project_fixture(attrs \\ %{}, admin_ids \\ []) do
    {:ok, project} =
      attrs
      |> Enum.into(%{
        name: "some name",
        desc: "some desc",
        dsn: "some dsn",
        image: "some image",
        organization_id: nil,
        admin_ids: admin_ids,
        member_ids: [],
        settings: %{}
      })
      |> ApiServer.Projects.create_project()

    project
  end
end

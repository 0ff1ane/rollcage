defmodule ApiServer.ProjectsTest do
  use ApiServer.DataCase

  alias ApiServer.Projects

  describe "projects" do
    alias ApiServer.Projects.Project

    import ApiServer.AccountsFixtures
    import ApiServer.ProjectsFixtures

    @invalid_attrs %{
      name: nil,
      desc: nil,
      image: nil,
      admin_ids: nil,
      member_ids: nil,
      settings: nil
    }

    test "list_projects/0 returns all projects" do
      user = user_fixture()
      organization = organization_fixture(%{}, [user.id])

      project =
        project_fixture(
          %{
            organization_id: organization.id,
            created_by_id: user.id
          },
          [user.id]
        )

      assert Projects.list_projects(user.id) == [project]
    end

    test "get_project!/1 returns the project with given id" do
      user = user_fixture()
      organization = organization_fixture(%{}, [user.id])

      project =
        project_fixture(
          %{
            organization_id: organization.id,
            created_by_id: user.id
          },
          [user.id]
        )

      assert Projects.get_project!(project.id) == project
    end

    test "create_project/1 with valid data creates a project" do
      user = user_fixture()
      organization = organization_fixture(%{}, [user.id])

      valid_attrs = %{
        name: "some name",
        desc: "some desc",
        image: "some image",
        admin_ids: [user.id],
        organization_id: organization.id,
        created_by_id: user.id,
        member_ids: [],
        settings: %{}
      }

      assert {:ok, %Project{} = project} = Projects.create_project(valid_attrs)
      assert project.name == "some name"
      assert project.desc == "some desc"
      assert project.admin_ids == [user.id]
      assert project.organization_id == organization.id
      assert project.member_ids == []
      assert project.settings == %{}

      {:ok, dsn} = Projects.get_dsn(project.id)
      assert String.ends_with?(dsn, String.replace(project.id, "-", "")) == true
    end

    test "create_project/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Projects.create_project(@invalid_attrs)
    end

    test "update_project/2 with valid data updates the project" do
      user = user_fixture()
      organization = organization_fixture(%{}, [user.id])

      project =
        project_fixture(%{organization_id: organization.id, created_by_id: user.id}, [
          user.id
        ])

      update_attrs = %{
        name: "some updated name",
        desc: "some updated desc",
        image: "some updated image",
        member_ids: [],
        settings: %{}
      }

      assert {:ok, %Project{} = project} = Projects.update_project(project, update_attrs)
      assert project.name == "some updated name"
      assert project.desc == "some updated desc"
      assert project.admin_ids == [user.id]
      assert project.member_ids == []
      assert project.settings == %{}

      {:ok, dsn} = Projects.get_dsn(project.id)
      assert String.ends_with?(dsn, String.replace(project.id, "-", "")) == true
    end

    test "update_project/2 with invalid data returns error changeset" do
      user = user_fixture()
      organization = organization_fixture(%{}, [user.id])

      project =
        project_fixture(%{organization_id: organization.id, created_by_id: user.id}, [
          user.id
        ])

      assert {:error, %Ecto.Changeset{}} = Projects.update_project(project, @invalid_attrs)
      assert project == Projects.get_project!(project.id)
    end

    test "change_project/1 returns a project changeset" do
      user = user_fixture()
      organization = organization_fixture(%{}, [user.id])

      project =
        project_fixture(%{organization_id: organization.id, created_by_id: user.id}, [
          user.id
        ])

      assert %Ecto.Changeset{} = Projects.change_project(project)
    end
  end
end

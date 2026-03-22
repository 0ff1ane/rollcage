defmodule ApiServer.AccountsTest do
  use ApiServer.DataCase

  alias ApiServer.Accounts

  describe "users" do
    alias ApiServer.Accounts.User

    import ApiServer.AccountsFixtures

    @invalid_attrs %{
      name: nil,
      email: nil,
      password: "password1",
      password_confirm: "password_no_match",
      profile_image: nil
    }

    test "list_users/0 returns all users" do
      user = user_fixture()
      [db_user] = Accounts.list_users()
      assert db_user.name == user.name
      assert db_user.email == user.email
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      db_user = Accounts.get_user!(user.id)
      assert db_user.email == user.email
      assert db_user.name == user.name
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{
        name: "some name",
        email: "some email",
        password: "mypassword",
        password_confirm: "mypassword",
        profile_image: "some profile_image"
      }

      assert {:ok, %User{} = user} = Accounts.create_user(valid_attrs)
      assert user.name == "some name"
      assert user.email == "some email"
      assert user.profile_image == "some profile_image"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()

      update_attrs = %{
        name: "some updated name",
        email: "some updated email",
        profile_image: "some updated profile_image"
      }

      assert {:ok, %User{} = user} = Accounts.update_user(user, update_attrs)
      assert user.name == "some updated name"
      # email does not change
      assert user.email != "some updated email"
      assert user.profile_image == "some updated profile_image"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      db_user = Accounts.get_user!(user.id)
      assert user.id == db_user.id
      assert user.email == db_user.email
      assert user.name == db_user.name
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "organizations" do
    alias ApiServer.Accounts.Organization

    import ApiServer.AccountsFixtures

    @invalid_attrs %{name: nil, desc: nil, admin_ids: nil, member_ids: nil}

    test "list_organizations/0 returns all organizations" do
      user = user_fixture()
      organization = organization_fixture(%{}, [user.id])
      assert Accounts.list_organizations(user.id) == [organization]
    end

    test "get_organization!/1 returns the organization with given id" do
      user = user_fixture()
      organization = organization_fixture(%{}, [user.id])
      assert Accounts.get_organization(organization.id, user.id) == {:ok, organization}
    end

    test "create_organization/1 with valid data creates a organization" do
      valid_attrs = %{name: "some name", desc: "some desc", admin_ids: [], member_ids: []}

      assert {:ok, %Organization{} = organization} = Accounts.create_organization(valid_attrs)
      assert organization.name == "some name"
      assert organization.desc == "some desc"
      assert organization.admin_ids == []
      assert organization.member_ids == []
    end

    test "create_organization/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_organization(@invalid_attrs)
    end

    test "update_organization/2 with valid data updates the organization" do
      user = user_fixture()
      organization = organization_fixture(%{}, [user.id])

      update_attrs = %{
        name: "some updated name",
        desc: "some updated desc",
        admin_ids: [],
        member_ids: []
      }

      assert {:ok, %Organization{} = organization} =
               Accounts.update_organization(organization, update_attrs)

      assert organization.name == "some updated name"
      assert organization.desc == "some updated desc"
      assert organization.admin_ids == []
      assert organization.member_ids == []
    end

    test "update_organization/2 with invalid data returns error changeset" do
      user = user_fixture()
      organization = organization_fixture(%{}, [user.id])

      assert {:error, %Ecto.Changeset{}} =
               Accounts.update_organization(organization, @invalid_attrs)

      assert {:ok, organization} == Accounts.get_organization(organization.id, user.id)
    end

    test "change_organization/1 returns a organization changeset" do
      organization = organization_fixture()
      assert %Ecto.Changeset{} = Accounts.change_organization(organization)
    end
  end
end

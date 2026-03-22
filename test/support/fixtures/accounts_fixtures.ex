defmodule ApiServer.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ApiServer.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "some.email@gg.com",
        name: "user name",
        password: "mypassword",
        password_confirm: "mypassword",
        profile_image: nil
      })
      |> ApiServer.Accounts.create_user()

    user
  end

  @doc """
  Generate a organization.
  """
  def organization_fixture(attrs \\ %{}, admin_ids \\ []) do
    {:ok, organization} =
      attrs
      |> Enum.into(%{
        admin_ids: admin_ids,
        desc: "some desc",
        member_ids: [],
        name: "some name"
      })
      |> ApiServer.Accounts.create_organization()

    organization
  end
end

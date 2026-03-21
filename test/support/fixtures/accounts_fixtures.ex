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
end

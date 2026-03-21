defmodule ApiServerWeb.UserControllerTest do
  use ApiServerWeb.ConnCase

  import ApiServer.AccountsFixtures
  alias ApiServer.Accounts
  alias ApiServer.Accounts.User

  @create_attrs %{
    name: "some name",
    email: "email@gg.com",
    password: "mypassword",
    password_confirm: "mypassword",
    profile_image: "some profile_image"
  }
  @update_attrs %{
    name: "some updated name",
    email: "email@gg.com",
    password: "somepassword",
    profile_image: "some updated profile_image"
  }
  @invalid_attrs %{
    name: nil,
    email: nil,
    password: "newpassword",
    password_confirm: "newpasword_mismatch",
    profile_image: nil
  }

  setup %{conn: conn} do
    {:ok, user} =
      %{
        "name" => "user name",
        "email" => "user@gg.com",
        "password" => "userpassword",
        "password_confirm" => "userpassword"
      }
      |> ApiServer.Accounts.create_user()

    user_token = Phoenix.Token.sign(ApiServerWeb.Endpoint, "userauth", user.id)

    {:ok,
     conn:
       conn
       |> put_req_header("accept", "application/json")
       |> put_req_header("authorization", user_token)}
  end

  describe "index" do
    test "lists all users", %{conn: conn} do
      conn = get(conn, ~p"/api/users")
      assert [_setup_user] = json_response(conn, 200)["data"]
    end
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      unauthenticated_conn = conn |> put_req_header("authorization", "")
      create_conn = post(unauthenticated_conn, ~p"/api/users", user: @create_attrs)

      assert %{"id" => id} = json_response(create_conn, 201)["data"]

      user = Accounts.get_user!(id)

      assert user.id == id
      assert user.email == "email@gg.com"
      assert user.name == "some name"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/users", user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user" do
    setup [:create_user]

    test "renders user when data is valid", %{conn: conn, user: %User{id: id} = user} do
      conn = put(conn, ~p"/api/users/#{user}", user: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/users/#{id}")

      user_email = user.email

      assert %{
               "id" => ^id,
               # email does not change
               "email" => ^user_email,
               "name" => "some updated name",
               "profile_image" => "some updated profile_image"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, ~p"/api/users/#{user}", user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  defp create_user(_) do
    user = user_fixture()

    %{user: user}
  end
end

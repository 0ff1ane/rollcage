defmodule ApiServerWeb.VerifyUserPlug do
  import Plug.Conn
  alias ApiServer.Accounts

  def init(options), do: options

  # This is what's get called
  def call(%Plug.Conn{} = conn, _opts) do
    with [token] <- conn |> get_req_header("authorization"),
         {:ok, user_id} <-
           Phoenix.Token.verify(ApiServerWeb.Endpoint, "userauth", token, max_age: 86400),
         user <- Accounts.get_user!(user_id) do
      conn
      |> assign(:current_user, user)
    else
      _ ->
        conn |> send_resp(401, ~c'{"error": "Not Authorized"}') |> halt()
    end
  end
end

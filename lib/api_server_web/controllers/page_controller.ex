defmodule ApiServerWeb.PageController do
  use ApiServerWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end

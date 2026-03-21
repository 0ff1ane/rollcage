defmodule ApiServerWeb.PageController do
  use ApiServerWeb, :controller

  def login(conn, _params) do
    conn
    |> assign_prop(:title, "Welcome to the login page")
    |> render_inertia("Login")
  end

  def counter(conn, _params) do
    conn
    |> assign_prop(:title, "A simple svelte counter")
    |> render_inertia("Counter")
  end

  def todos(conn, _params) do
    conn
    |> assign_prop(:title, "A simple svelte todo app")
    |> render_inertia("Todos")
  end
end

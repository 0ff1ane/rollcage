defmodule ApiServerWeb.PageControllerTest do
  use ApiServerWeb.ConnCase

  import Inertia.Testing

  describe "GET /" do
    test "renders the home page", %{conn: conn} do
      conn = get(conn, "/")
      assert inertia_component(conn) == "Home"

      page_props = inertia_props(conn)

      assert %{
               # from home() controller props
               title: "Welcome to the home page"
             } = page_props
    end
  end
end

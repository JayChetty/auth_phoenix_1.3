defmodule AuthWeb.SessionControllerTest do
  use AuthWeb.ConnCase


  describe "new session" do
    test "renders form", %{conn: conn} do
      conn = get conn, session_path(conn, :new)
      assert html_response(conn, 200) =~ "Login"
    end
  end
end

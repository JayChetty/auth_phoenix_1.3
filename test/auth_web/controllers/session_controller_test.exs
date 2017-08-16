defmodule AuthWeb.SessionControllerTest do
  use AuthWeb.ConnCase
  alias Auth.Accounts

  @create_attrs %{email: "person@email.com", password: "password"}

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end

  describe "new session" do
    test "renders form", %{conn: conn} do
      conn = get conn, session_path(conn, :new)
      assert html_response(conn, 200) =~ "Login"
    end
  end

  describe "create session" do
    setup [:create_user]
    test "puts the user in the session", %{conn: conn} do
      conn = post conn, session_path(conn, :create)
      assert html_response(conn, 200) =~ "Login"
    end
  end
end

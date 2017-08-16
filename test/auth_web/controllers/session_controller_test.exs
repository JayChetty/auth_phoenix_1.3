defmodule AuthWeb.SessionControllerTest do
  use AuthWeb.ConnCase
  alias Auth.Accounts
  require Logger

  @user_attrs %{email: "person@email.com", password: "password"}
  @create_attrs %{ session: @user_attrs}


  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@user_attrs)
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
    #What is a better way to test these things.  I like to have them proded but
    #coul be better
    setup [:create_user]
    test "redirects when correct user", %{conn: conn} do
      conn = post conn, session_path(conn, :create), @create_attrs
      assert html_response(conn, 302)

    end

    test "renders new when incorrect details", %{conn: conn} do
      wrong_password_attrs = put_in(@create_attrs, [:session, :password], "hackerz")
      conn = post conn, session_path(conn, :create), wrong_password_attrs
      assert html_response(conn, 200)
      # want a simple test here to check conn has a token
      # conn.private.guardian_default_resource
    end
  end
end

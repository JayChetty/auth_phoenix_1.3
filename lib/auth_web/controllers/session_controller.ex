defmodule AuthWeb.SessionController do
  use AuthWeb, :controller

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, %{"session" => %{"email" => email, "password" => password}}) do
    case Auth.Accounts.authenticate_user(%{email: email, password: password}) do
      {:ok, user} ->
        conn
        |> Guardian.Plug.sign_in(user)
        |> put_flash(:info, "Succesfully signed in.")
        |> redirect( to: "/" )
      :error ->
        conn
        |> put_flash(:info, "Invalid username/password combination")
        |> render("new.html")
    end
  end
end

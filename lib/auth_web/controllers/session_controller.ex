defmodule AuthWeb.SessionController do
  use AuthWeb, :controller

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, %{"session" => session_params}) do
    case Accounts.authenticate(session_params) do
      {:ok, user} ->
      :error ->
    end
  end
end

defmodule AuthWeb.SessionController do
  use AuthWeb, :controller

  def new(conn, _params) do
    render conn, "new.html"
  end
end

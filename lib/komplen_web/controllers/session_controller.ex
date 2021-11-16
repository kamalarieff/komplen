defmodule KomplenWeb.SessionController do
  use KomplenWeb, :controller

  alias Komplen.Accounts

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"user" => %{"name" => name}}) do
    case Accounts.authenticate_by_username(name) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome #{name}")
        |> put_session(:user_id, user.id)
        |> configure_session(renew: true)
        |> redirect(to: Routes.complaint_index_path(conn, :index))

      {:error, :unauthorized} ->
        conn
        |> put_flash(:error, "Bad name")
        |> redirect(to: Routes.session_path(conn, :new))
    end
  end

  def delete(conn, _) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end
end

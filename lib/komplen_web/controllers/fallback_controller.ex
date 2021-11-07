defmodule KomplenWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use KomplenWeb, :controller

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(KomplenWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(KomplenWeb.ErrorView)
    |> render(:"404")
  end

  # This clause is an example of how to handle invalid params
  def call(conn, {:error, :unprocessable_entity}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(KomplenWeb.ErrorView)
    |> render(:"422")
  end

  # This clause is an example of how to handle unauthorized
  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_flash(:error, "You must sign up first.")
    |> redirect(to: Routes.user_path(conn, :new))
  end
end

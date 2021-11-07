defmodule KomplenWeb.VouchController do
  use KomplenWeb, :controller

  alias Komplen.Complaints
  alias Komplen.Complaints.Vouch
  alias KomplenWeb.ComplaintView

  action_fallback KomplenWeb.FallbackController

  # not sure if this is the recommended way to do it
  def create(_, attrs) when map_size(attrs) == 0, do: {:error, :unprocessable_entity}

  def create(conn, %{"complaint_id" => complaint_id}) do
    # TODO: maybe think about whether to pass user_id through the function instead
    # it makes testing easier,
    # but it wouldn't be secure because you can pass in the user id via post params
    user_id = get_session(conn, "user_id")

    case user_id do
      nil ->
        {:error, :unauthorized}

      _ ->
        with {:ok, %Vouch{} = vouch} <-
               Complaints.add_vouch(%{user_id: user_id, complaint_id: complaint_id}),
             complaint <- Complaints.get_complaint!(complaint_id) do
          conn
          # TODO: This is not correct because the URL shows /vouches instead of /complaints
          |> put_view(ComplaintView)
          |> render("show.html", complaint: complaint, vouch_id: vouch.id)
        end
    end
  end

  def delete(conn, %{"id" => vouch_id}) do
    vouch = Complaints.get_vouch!(vouch_id)

    with complaint <- Complaints.get_complaint!(vouch.complaint_id),
         {:ok, %Vouch{}} <- Complaints.remove_vouch(vouch) do
      conn
      # TODO: This is not correct because the URL shows /vouches instead of /complaints
      |> put_view(ComplaintView)
      |> render("show.html", complaint: complaint, vouch_id: nil)
    end
  end
end

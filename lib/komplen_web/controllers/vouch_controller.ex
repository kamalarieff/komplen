defmodule KomplenWeb.VouchController do
  use KomplenWeb, :controller

  alias Komplen.Complaints
  alias Komplen.Complaints.Vouch

  action_fallback KomplenWeb.FallbackController

  def index(conn, _params) do
    vouches = Complaints.list_vouches()
    render(conn, "index.json", vouches: vouches)
  end

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
               Complaints.add_vouch(%{user_id: user_id, complaint_id: complaint_id}) do
          conn
          |> put_status(:created)
          |> put_resp_header("location", Routes.vouch_path(conn, :show, vouch))
          |> render("show.json", vouch: vouch)
        end
    end
  end

  def show(conn, %{"id" => vouch_id}) do
    vouch = Complaints.get_vouch!(vouch_id)
    render(conn, "show.json", vouch: vouch)
  end

  def delete(conn, %{"id" => vouch_id}) do
    vouch = Complaints.get_vouch!(vouch_id)

    with {:ok, %Vouch{}} <- Complaints.remove_vouch(vouch) do
      send_resp(conn, :no_content, "")
    end
  end
end

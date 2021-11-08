defmodule KomplenWeb.VouchController do
  use KomplenWeb, :controller

  alias Komplen.Complaints
  alias Komplen.Accounts
  alias Komplen.Complaints.Vouch

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
        # YOGHIRT Using with clause with guards
        # https://blog.sundaycoding.com/blog/2017/12/27/elixir-with-syntax-and-guard-clauses/
        with profile when not is_nil(profile) <- Accounts.get_profile_by_user_id(user_id) do
          with {:ok, %Vouch{}} <-
                 Complaints.add_vouch(%{user_id: user_id, complaint_id: complaint_id}) do
            conn
            |> redirect(to: Routes.complaint_path(conn, :show, complaint_id))
          end
        else
          nil ->
            {:error, :profile_not_found}
        end
    end
  end

  def delete(conn, %{"id" => vouch_id}) do
    user_id = get_session(conn, "user_id")
    vouch = Complaints.get_vouch!(vouch_id)

    case user_id do
      nil ->
        {:error, :unauthorized}

      _ ->
        with {:ok, %Vouch{}} <- Complaints.remove_vouch(vouch) do
          conn
          |> redirect(to: Routes.complaint_path(conn, :show, vouch.complaint_id))
        end
    end
  end
end

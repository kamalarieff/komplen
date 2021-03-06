defmodule KomplenWeb.ProfileController do
  use KomplenWeb, :controller

  alias Komplen.Accounts
  alias Komplen.Accounts.Profile

  def show(conn, _params) do
    user =
      conn
      |> get_session("user")

    profile = Accounts.get_profile(%{user_id: user.id})

    case profile do
      nil ->
        render(conn, "show.html", profile: %Profile{})

      _ ->
        render(conn, "show.html", profile: profile)
    end
  end

  def edit(conn, _params) do
    user =
      conn
      |> get_session("user")

    profile = Accounts.get_profile(%{user_id: user.id})

    case profile do
      nil ->
        profile = %Profile{}
        changeset = Accounts.change_profile(profile)
        render(conn, "edit.html", changeset: changeset)

      _ ->
        changeset = Accounts.change_profile(profile)
        render(conn, "edit.html", changeset: changeset)
    end
  end

  def update(conn, %{"profile" => profile_params}) do
    user_id =
      conn
      |> get_session("user_id")

    profile = Accounts.get_profile(%{user_id: user_id})

    case profile do
      nil ->
        {:ok, profile} =
          Map.put(profile_params, "user_id", user_id)
          |> Accounts.create_profile()

        conn
        |> put_flash(:info, "Profile updated successfully.")
        |> assign(:profile, profile)
        # YOGHIRT for singleton, don't have to pass the profile to the html
        |> redirect(to: Routes.profile_path(conn, :show))

      _ ->
        case Accounts.update_profile(profile, profile_params) do
          {:ok, _profile} ->
            conn
            |> put_flash(:info, "Profile updated successfully.")
            # YOGHIRT for singleton, don't have to pass the profile to the html
            |> redirect(to: Routes.profile_path(conn, :show))

          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, "edit.html", changeset: changeset)
        end
    end
  end
end

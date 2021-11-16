defmodule KomplenWeb.UserLive.Show do
  use KomplenWeb, :live_view

  alias Komplen.Accounts

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:user, Accounts.get_user!(id))}
  end
  
  @impl true
  def handle_event("make_admin", _params, socket) do
    save_admin(socket, :new, %{"user" => socket.assigns.user})
  end

  defp page_title(:show), do: "Show User"
  defp page_title(:edit), do: "Edit User"

  defp save_admin(socket, :new, %{"user" => user}) do
    case Accounts.create_admin(user) do
      {:ok, _admin} ->
        {:noreply,
         socket
         |> put_flash(:info, "Admin created successfully")
         |> push_redirect(to: Routes.user_show_path(socket, :show, user))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

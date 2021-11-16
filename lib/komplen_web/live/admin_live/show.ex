defmodule KomplenWeb.AdminLive.Show do
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
     |> assign(:admin, Accounts.get_admin!(id))}
  end

  @impl true
  def handle_event("remove_admin", _, socket) do
    admin = socket.assigns.admin
    {:ok, _} = Accounts.delete_admin(admin)

    {:noreply,
     socket
     |> put_flash(:info, "Admin removed successfully")
     |> push_redirect(to: Routes.admin_index_path(socket, :index))}
  end

  defp page_title(:show), do: "Show Admin"
  defp page_title(:edit), do: "Edit Admin"
end

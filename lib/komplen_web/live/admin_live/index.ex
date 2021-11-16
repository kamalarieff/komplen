defmodule KomplenWeb.AdminLive.Index do
  use KomplenWeb, :live_view

  alias Komplen.Accounts
  alias Komplen.Accounts.Admin

  @impl true
  def mount(_params, _session, socket) do
    # {:ok, assign(socket, :admins, list_admins())}
    {:ok,
     socket
     |> assign(admins: list_admins(), users: list_users())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Admin")
    |> assign(:admin, Accounts.get_admin!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Admin")
    |> assign(:admin, %Admin{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Admins")
    |> assign(:admin, nil)
  end

  @impl true
  def handle_event("remove_admin", %{"admin_id" => admin_id}, socket) do
    admin = Accounts.get_admin!(admin_id)
    {:ok, _} = Accounts.delete_admin(admin)

    {:noreply,
     socket
     |> put_flash(:info, "Admin removed successfully")
     |> push_redirect(to: Routes.admin_index_path(socket, :index))}
  end

  @impl true
  def handle_event("make_admin", params, socket) do
    save_admin(socket, :new, params)
  end

  defp list_users do
    Accounts.list_users()
  end

  defp list_admins do
    Accounts.list_admins()
  end

  defp save_admin(socket, :edit, admin_params) do
    case Accounts.update_admin(socket.assigns.admin, admin_params) do
      {:ok, _admin} ->
        {:noreply,
         socket
         |> put_flash(:info, "Admin updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_admin(socket, :new, %{"user_id" => user_id}) do
    user = Accounts.get_user!(user_id)

    case Accounts.create_admin(user) do
      {:ok, _admin} ->
        {:noreply,
         socket
         |> put_flash(:info, "Admin created successfully")
         |> push_redirect(to: Routes.admin_index_path(socket, :index))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

defmodule KomplenWeb.AdminLive.FormComponent do
  use KomplenWeb, :live_component

  alias Komplen.Accounts

  @impl true
  def update(%{admin: admin} = assigns, socket) do
    changeset = Accounts.change_admin(admin)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"admin" => admin_params}, socket) do
    changeset =
      socket.assigns.admin
      |> Accounts.change_admin(admin_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"admin" => admin_params}, socket) do
    save_admin(socket, socket.assigns.action, admin_params)
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

  defp save_admin(socket, :new, admin_params) do
    case Accounts.create_admin(admin_params) do
      {:ok, _admin} ->
        {:noreply,
         socket
         |> put_flash(:info, "Admin created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

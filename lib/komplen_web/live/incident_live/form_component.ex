defmodule KomplenWeb.IncidentLive.FormComponent do
  use KomplenWeb, :live_component

  alias Komplen.Complaints

  @impl true
  def update(%{incident: incident} = assigns, socket) do
    changeset = Complaints.change_incident(incident)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"incident" => incident_params}, socket) do
    changeset =
      socket.assigns.incident
      |> Complaints.change_incident(incident_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"incident" => incident_params}, socket) do
    save_incident(socket, socket.assigns.action, incident_params)
  end

  defp save_incident(socket, :edit, incident_params) do
    case Complaints.update_incident(socket.assigns.incident, incident_params) do
      {:ok, _incident} ->
        {:noreply,
         socket
         |> put_flash(:info, "Incident updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_incident(socket, :new, incident_params) do
    case Complaints.create_incident(incident_params) do
      {:ok, _incident} ->
        {:noreply,
         socket
         |> put_flash(:info, "Incident created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

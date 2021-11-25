defmodule KomplenWeb.IncidentLive.Index do
  use KomplenWeb, :live_view

  alias Komplen.Complaints
  alias Komplen.Complaints.Incident

  @impl true
  def mount(%{"complaint_id" => complaint_id}, session, socket) do
    user_id = Map.get(session, "user_id")

    {:ok,
     socket
     |> assign(:incidents, list_incidents(complaint_id))
     |> assign(:user_id, user_id)
     |> assign(:complaint_id, complaint_id)}
  end

  @impl true
  def handle_params(params, _url, socket) when socket.assigns.live_action in [:edit, :new] do
    case is_nil(socket.assigns.user_id) do
      true ->
        {:noreply,
         socket
         |> redirect(to: Routes.session_path(socket, :new))}

      _ ->
        {:noreply, apply_action(socket, socket.assigns.live_action, params)}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Incident")
    |> assign(:incident, Complaints.get_incident!(id))
  end

  defp apply_action(socket, :new, params) do
    %{"complaint_id" => complaint_id} = params
    user_id = socket.assigns.user_id

    socket
    |> assign(:page_title, "New Incident")
    |> assign(:incident, %Incident{user_id: user_id, complaint_id: complaint_id})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Incidents")
    |> assign(:incident, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    incident = Complaints.get_incident!(id)
    {:ok, _} = Complaints.delete_incident(incident)

    {:noreply, assign(socket, :incidents, list_incidents(incident.complaint_id))}
  end

  defp list_incidents(complaint_id) do
    Complaints.list_incidents(%{complaint_id: complaint_id})
  end
end

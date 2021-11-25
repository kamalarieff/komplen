defmodule KomplenWeb.IncidentLive.Show do
  use KomplenWeb, :live_view

  alias Komplen.Complaints

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"complaint_id" => complaint_id, "incident_id" => incident_id}, _, socket) do
    IO.inspect(complaint_id, label: "complaint_id")
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:incident, Complaints.get_incident!(incident_id))}
  end

  defp page_title(:show), do: "Show Incident"
  defp page_title(:edit), do: "Edit Incident"
end

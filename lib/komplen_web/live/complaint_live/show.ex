defmodule KomplenWeb.ComplaintLive.Show do
  use KomplenWeb, :live_view

  alias Komplen.Complaints

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:complaint, Complaints.get_complaint!(id))}
  end

  defp page_title(:show), do: "Show Complaint"
  defp page_title(:edit), do: "Edit Complaint"
end

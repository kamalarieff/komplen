defmodule KomplenWeb.ComplaintLive.Show do
  use KomplenWeb, :live_view

  alias Komplen.Complaints

  @impl true
  def mount(_params, session, socket) do
    user_id = Map.get(session, "user_id")
    {:ok, assign(socket, :user_id, user_id)}
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

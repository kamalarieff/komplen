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
    complaint_topic = topic(id)
    KomplenWeb.Endpoint.subscribe(complaint_topic)
    num_vouches = Complaints.get_number_of_vouches_by_complaint_id(id)

    vouch_id =
      Complaints.get_vouch_by_complaint_id_and_user_id(id, socket.assigns.user_id)
      |> case do
        nil -> nil
        vouch -> vouch.id
      end

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:complaint, Complaints.get_complaint!(id))
     |> assign(:num_vouches, num_vouches)
     |> assign(:vouch_id, vouch_id)}
  end

  @impl true
  def handle_event("add_vouch", %{"complaint_id" => complaint_id}, socket) do
    complaint_topic = topic(complaint_id)

    {:ok, _vouch} =
      Complaints.add_vouch(%{user_id: socket.assigns.user_id, complaint_id: complaint_id})

    KomplenWeb.Endpoint.broadcast(complaint_topic, "add_vouch", nil)
    {:noreply, socket}
  end

  @impl true
  def handle_event("remove_vouch", %{"complaint_id" => complaint_id}, socket) do
    complaint_topic = topic(complaint_id)
    vouch = Complaints.get_vouch_by_complaint_id(complaint_id)

    {:ok, _vouch} = Complaints.remove_vouch(vouch)

    KomplenWeb.Endpoint.broadcast(complaint_topic, "remove_vouch", nil)
    {:noreply, socket}
  end

  @impl true
  def handle_info(%{event: "add_vouch"}, socket) do
    {:noreply, update(socket, :num_vouches, fn x -> x + 1 end)}
  end

  @impl true
  def handle_info(%{event: "remove_vouch"}, socket) do
    {:noreply, update(socket, :num_vouches, fn x -> x - 1 end)}
  end

  defp topic(id), do: "complaint:#{id}"

  defp page_title(:show), do: "Show Complaint"
  defp page_title(:edit), do: "Edit Complaint"
end

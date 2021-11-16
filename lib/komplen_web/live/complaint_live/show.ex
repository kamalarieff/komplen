defmodule KomplenWeb.ComplaintLive.Show do
  use KomplenWeb, :live_view

  alias Komplen.Complaints

  @impl true
  def mount(_params, session, socket) do
    user_id = Map.get(session, "user_id")
    admin_id = Map.get(session, "admin_id")

    {:ok,
     socket
     |> assign(:user_id, user_id)
     |> assign(:admin_id, admin_id)
     |> assign(:status, "In Progress")}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    vouches = Complaints.list_vouches({:complaint_id, id})

    vouch_id =
      vouches
      |> Enum.find(fn x ->
        x.user_id == socket.assigns.user_id
      end)
      |> case do
        nil -> nil
        vouch -> vouch.id
      end

    complaint_topic = topic(id)
    KomplenWeb.Endpoint.subscribe(complaint_topic)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:complaint, Complaints.get_complaint!(id))
     |> assign(:num_vouches, length(vouches))
     |> assign(:vouch_id, vouch_id)}
  end

  @impl true
  def handle_event("add_vouch", %{"complaint_id" => complaint_id}, socket) do
    complaint_topic = topic(complaint_id)

    case is_nil(socket.assigns.user_id) do
      true ->
        {:noreply,
         socket
         |> redirect(to: Routes.session_path(socket, :new))}

      _ ->
        {:ok, vouch} =
          Complaints.add_vouch(%{user_id: socket.assigns.user_id, complaint_id: complaint_id})

        KomplenWeb.Endpoint.broadcast(complaint_topic, "add_vouch", nil)
        {:noreply, assign(socket, :vouch_id, vouch.id)}
    end
  end

  @impl true
  def handle_event("remove_vouch", %{"complaint_id" => complaint_id}, socket) do
    complaint_topic = topic(complaint_id)

    vouch =
      Complaints.get_vouch([{:complaint_id, complaint_id}, {:user_id, socket.assigns.user_id}])

    {:ok, _vouch} = Complaints.remove_vouch(vouch)

    KomplenWeb.Endpoint.broadcast(complaint_topic, "remove_vouch", nil)
    {:noreply, assign(socket, :vouch_id, nil)}
  end

  @impl true
  def handle_event("change_status", %{"to_status" => to_status}, socket)
      when to_status == "done" do
    complaint_topic = topic(socket.assigns.complaint.id)
    KomplenWeb.Endpoint.broadcast(complaint_topic, "change_status", :done)

    notify_status_change(:done, socket)
  end

  @impl true
  def handle_event("change_status", %{"to_status" => to_status}, socket)
      when to_status == "in progress" do
    complaint_topic = topic(socket.assigns.complaint.id)
    KomplenWeb.Endpoint.broadcast(complaint_topic, "change_status", :in_progress)

    notify_status_change(:in_progress, socket)
  end

  @impl true
  def handle_info(%{event: "update", payload: complaint}, socket) do
    {:noreply, assign(socket, :complaint, complaint)}
  end

  @impl true
  def handle_info(%{event: "add_vouch"}, socket) do
    {:noreply, update(socket, :num_vouches, fn x -> x + 1 end)}
  end

  @impl true
  def handle_info(%{event: "remove_vouch"}, socket) do
    {:noreply, update(socket, :num_vouches, fn x -> x - 1 end)}
  end

  @impl true
  def handle_info(%{event: "change_status", payload: payload}, socket) do
    notify_status_change(payload, socket)
  end

  defp topic(id), do: "complaint:#{id}"

  defp page_title(:show), do: "Show Complaint"
  defp page_title(:edit), do: "Edit Complaint"

  defp notify_status_change(:done, socket) do
    {:noreply,
     socket
     |> assign(:status, "Done")
     |> put_flash(:info, "Status changed to Done")}
  end

  defp notify_status_change(:in_progress, socket) do
    {:noreply,
     socket
     |> assign(:status, "In Progress")
     |> put_flash(:info, "Status changed to In Progress")}
  end
end

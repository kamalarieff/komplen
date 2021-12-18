defmodule KomplenWeb.ComplaintLive.Index do
  use KomplenWeb, :live_view

  alias Komplen.Complaints
  alias Komplen.Complaints.Complaint

  @complaints_topic "complaints:*"

  @impl true
  def mount(_params, session, socket) do
    user_id = Map.get(session, "user_id")
    KomplenWeb.Endpoint.subscribe(@complaints_topic)

    socket =
      socket
      |> assign(:complaints, list_complaints())
      |> assign(:user_id, user_id)
      |> assign(:search_term, "")

    {:ok, assign(socket, temporary_assigns: [complaints: []])}
  end

  @impl true
  def handle_params(_params, _url, socket)
      when socket.assigns.live_action in [:new, :edit] and is_nil(socket.assigns.user_id) do
    {:noreply,
     socket
     |> put_flash(:error, "You must log in first.")
     |> redirect(to: Routes.session_path(socket, :new))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_info(%{event: "save", payload: complaint}, socket) do
    {:noreply,
     update(socket, :complaints, fn complaints ->
       complaints ++ [complaint]
     end)}
  end

  @impl true
  def handle_info(%{event: "update", payload: complaint}, socket) do
    # {:noreply,
    #  update(socket, :complaints, fn complaints ->
    #    Enum.map(complaints, fn x -> 
    #      if x.id == complaint.id, do: complaint, else: x end
    #    )
    #  end)}
    # TODO: this is bad UI because whoever is on page will see the complaints jump around
    # I think it's better if you don't update this page as frequent
    # a better UI is to show a notification when a new complaint has arrived
    {:noreply,
     socket
     |> push_redirect(to: Routes.complaint_index_path(socket, :index))}
  end

  @impl true
  def handle_event("search", %{"value" => value}, socket) when value == "" do
    {:noreply, assign(socket, search_term: "", complaints: list_complaints())}
  end

  # TODO: I had to remove the phx-update=append in order to make this work
  @impl true
  def handle_event("search", %{"value" => value}, socket) do
    complaints = Complaints.search_complaints(value)
    {:noreply, assign(socket, search_term: value, complaints: complaints)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    complaint = Complaints.get_complaint!(id)
    {:ok, _} = Complaints.delete_complaint(complaint)
    {:noreply, assign(socket, complaints: list_complaints())}
  end

  @impl true
  def handle_event("save-my-location", params, socket) do
    %{"latlng" => %{"lat" => lat, "lng" => lng}} = params

    {:noreply,
     socket
     |> assign(:lat, lat)
     |> assign(:lng, lng)}
  end

  defp check_complaint_belong_to_user(complaint_id, user_id) do
    complaint = Complaints.get_complaint!(complaint_id)
    complaint.user_id == user_id
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    case check_complaint_belong_to_user(id, socket.assigns.user_id) do
      false ->
        socket
        |> put_flash(:error, "You are not the owner of this complaint.")
        |> redirect(to: Routes.complaint_index_path(socket, :index))

      true ->
        socket
        |> assign(:page_title, "Edit Complaint")
        |> assign(:complaint, Complaints.get_complaint!(id))
    end
  end

  defp apply_action(socket, :new, _params) do
    user_id = socket.assigns.user_id

    socket
    |> assign(:page_title, "New Complaint")
    |> assign(:complaint, %Complaint{user_id: user_id})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Complaints")
    |> assign(:complaint, nil)
  end

  defp list_complaints do
    Complaints.list_complaints()
  end
end

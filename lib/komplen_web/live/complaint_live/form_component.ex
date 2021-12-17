defmodule KomplenWeb.ComplaintLive.FormComponent do
  use KomplenWeb, :live_component

  alias Komplen.Complaints

  # TODO: this is duplicated code. Try to find a better way
  @complaints_topic "complaints:*"
  @default_lat 3.0482683245978155
  @default_lng 101.58587425947192

  @impl true
  def update(%{complaint: complaint} = assigns, socket) do
    changeset = Complaints.change_complaint(complaint)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"complaint" => complaint_params}, socket) do
    changeset =
      socket.assigns.complaint
      |> Complaints.change_complaint(complaint_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("save-my-location", %{"latlng" => %{"lat" => lat, "lng" => lng}}, socket) do
    changeset =
      socket.assigns.complaint
      |> Complaints.change_complaint(%{lat: lat, lng: lng})

    {:noreply,
     socket
     |> push_event("update-marker", %{lat: lat, lng: lng})
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("move-marker", %{"latlng" => %{"lat" => lat, "lng" => lng}}, socket) do
    changeset =
      socket.assigns.complaint
      |> Complaints.change_complaint(%{lat: lat, lng: lng})

    {:noreply,
     socket
     |> push_event("update-marker", %{lat: lat, lng: lng})
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"complaint" => complaint_params}, socket) do
    save_complaint(socket, socket.assigns.action, complaint_params)
  end

  defp save_complaint(socket, :edit, complaint_params) do
    case Complaints.update_complaint(socket.assigns.complaint, complaint_params) do
      {:ok, complaint} ->
        KomplenWeb.Endpoint.broadcast(@complaints_topic, "update", complaint)
        KomplenWeb.Endpoint.broadcast(topic(socket.assigns.complaint.id), "update", complaint)

        {:noreply,
         socket
         |> put_flash(:info, "Complaint updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_complaint(socket, :new, complaint_params) do
    user_id = socket.assigns.user_id

    case Complaints.create_complaint(Map.put(complaint_params, "user_id", user_id)) do
      {:ok, complaint} ->
        KomplenWeb.Endpoint.broadcast(@complaints_topic, "save", complaint)

        {:noreply,
         socket
         |> put_flash(:info, "Complaint created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp topic(id), do: "complaint:#{id}"
  def default_lat, do: @default_lat
  def default_lng, do: @default_lng
end

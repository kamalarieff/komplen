defmodule KomplenWeb.ComplaintLive.FormComponent do
  use KomplenWeb, :live_component

  alias Komplen.{Complaints, Chat}

  # TODO: this is duplicated code. Try to find a better way
  @complaints_topic "complaints:*"
  @default_lat 3.0482683245978155
  @default_lng 101.58587425947192

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> allow_upload(:avatar, accept: ~w(.jpg .jpeg .png), max_entries: 2)}
  end

  @impl true
  def update(%{complaint: complaint} = assigns, socket) do
    changeset = Complaints.change_complaint(complaint)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign(:uploaded_files, complaint.photo_urls)}
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
    uploaded_files =
      case uploaded_entries(socket, :avatar) do
        {entries, []} ->
          for entry <- entries do
            consume_uploaded_entry(socket, entry, fn %{path: path} ->
              dest =
                Path.join([
                  :code.priv_dir(:komplen),
                  "static",
                  "uploads",
                  Path.basename(path) <> ".#{ext(entry)}"
                ])

              File.cp!(path, dest)
              Routes.static_path(socket, "/uploads/#{Path.basename(dest)}")
            end)
          end

        _ ->
          []
      end

    complaint_params =
      complaint_params
      |> Map.put("photo_urls", socket.assigns.uploaded_files ++ uploaded_files)

    save_complaint(socket, socket.assigns.action, complaint_params)
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :avatar, ref)}
  end

  @impl true
  def handle_event("remove-uploaded", %{"url" => url}, socket) do
    path = Path.join([:code.priv_dir(:komplen), "static", url])
    File.rm!(path)
    {:noreply,
     update(socket, :uploaded_files, fn uploaded_files ->
       Enum.reject(uploaded_files, &(&1 == url))
     end)}
  end

  defp ext(entry) do
    [ext | _] = MIME.extensions(entry.client_type)
    ext
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
        Chat.create_room(%{complaint_id: complaint.id})

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

  def error_to_string(:too_large), do: "Too large"
  def error_to_string(:too_many_files), do: "You have selected too many files"
  def error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
end

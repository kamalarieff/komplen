defmodule KomplenWeb.ComplaintLive.Index do
  use KomplenWeb, :live_view

  alias Komplen.Complaints
  alias Komplen.Complaints.Complaint

  @impl true
  def mount(_params, session, socket) do
    user_id = Map.get(session, "user_id")

    socket =
      socket
      |> assign(:complaints, list_complaints())
      |> assign(:user_id, user_id)

    {:ok, assign(socket, :complaints, list_complaints())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Complaint")
    |> assign(:complaint, Complaints.get_complaint!(id))
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

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    complaint = Complaints.get_complaint!(id)
    {:ok, _} = Complaints.delete_complaint(complaint)

    {:noreply, assign(socket, :complaints, list_complaints())}
  end

  defp list_complaints do
    Complaints.list_complaints()
  end
end

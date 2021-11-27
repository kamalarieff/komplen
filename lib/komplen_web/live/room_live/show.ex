defmodule KomplenWeb.RoomLive.Show do
  use KomplenWeb, :live_view

  alias Komplen.Chat
  alias Komplen.Chat.Message

  @impl true
  def mount(_params, session, socket) do
    user_id = Map.get(session, "user_id")

    {:ok,
     socket
     |> assign(:user_id, user_id)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    room = Chat.get_room!(id)
    chat_changeset = Chat.change_message(%Message{room_id: room.id})
    topic = topic(id)

    KomplenWeb.Endpoint.subscribe(topic)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:room, room)
     |> assign(:chat_changeset, chat_changeset)}
  end

  @impl true
  def handle_event("validate_chat", %{"message" => message_params}, socket) do
    changeset =
      %Message{}
      |> Chat.change_message(message_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :chat_changeset, changeset)}
  end

  @impl true
  def handle_event("save_chat", %{"message" => %{"message" => message}}, socket) do
    room_id = socket.assigns.room.id
    user_id = socket.assigns.user_id
    topic = topic(room_id)
    Chat.create_message(%{message: message, user_id: user_id, room_id: room_id})
    KomplenWeb.Endpoint.broadcast(topic, "send_message", room_id)

    {:noreply,
     socket
     |> push_redirect(to: Routes.room_show_path(socket, :show, room_id))}
  end

  @impl true
  def handle_info(%{event: "send_message", payload: room_id}, socket) do
    {:noreply,
     socket
     |> push_redirect(to: Routes.room_show_path(socket, :show, room_id))}
  end

  defp page_title(:show), do: "Show Room"
  defp page_title(:edit), do: "Edit Room"

  defp topic(id), do: "room:#{id}"

  defp is_admin(admin) do
    case admin do
      nil -> nil
      _ -> "admin"
    end
  end
end

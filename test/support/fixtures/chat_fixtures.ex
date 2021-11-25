defmodule Komplen.ChatFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Komplen.Chat` context.
  """

  @doc """
  Generate a room.
  """
  def room_fixture(attrs \\ %{}) do
    {:ok, room} =
      attrs
      |> Enum.into(%{
        room_id: "7488a646-e31f-11e4-aace-600308960662"
      })
      |> Komplen.Chat.create_room()

    room
  end

  @doc """
  Generate a message.
  """
  def message_fixture(attrs \\ %{}) do
    {:ok, message} =
      attrs
      |> Enum.into(%{
        message: "some message"
      })
      |> Komplen.Chat.create_message()

    message
  end
end

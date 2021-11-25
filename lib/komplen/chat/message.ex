defmodule Komplen.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :message, :string
    belongs_to :user, Komplen.Accounts.User
    belongs_to :room, Komplen.Chat.Room

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:message, :user_id, :room_id])
    |> validate_required([:message, :user_id, :room_id])
    |> assoc_constraint(:user)
    |> assoc_constraint(:room)
  end
end

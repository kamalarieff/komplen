defmodule Komplen.Chat.Room do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rooms" do
    belongs_to :complaint, Komplen.Complaints.Complaint
    has_many :messages, Komplen.Chat.Message

    timestamps()
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:complaint_id])
    |> validate_required(:complaint_id)
    |> assoc_constraint(:complaint)
  end
end

defmodule Komplen.Complaints.Complaint do
  use Ecto.Schema
  import Ecto.Changeset

  alias Komplen.Accounts.User
  alias Komplen.Chat.Room

  schema "complaints" do
    field :body, :string
    field :title, :string
    field :status, :string
    field :lat, :string
    field :lng, :string
    field :photo_urls, {:array, :string}, default: []
    belongs_to :user, User
    has_one :room, Room

    timestamps()
  end

  @doc false
  def changeset(complaint, attrs) do
    complaint
    |> cast(attrs, [:title, :body, :status, :lat, :lng, :photo_urls])
    |> validate_required([:title, :body, :user_id])
    |> check_constraint(:status, name: :allowed_status)
    |> assoc_constraint(:user)
  end
end

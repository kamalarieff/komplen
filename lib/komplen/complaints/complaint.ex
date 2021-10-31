defmodule Komplen.Complaints.Complaint do
  use Ecto.Schema
  import Ecto.Changeset

  alias Komplen.Accounts.User

  schema "complaints" do
    field :body, :string
    field :title, :string
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(complaint, attrs) do
    complaint
    |> cast(attrs, [:title, :body])
    |> validate_required([:title, :body])
    |> validate_required([:user_id])
    |> Ecto.Changeset.assoc_constraint(:user)
  end
end

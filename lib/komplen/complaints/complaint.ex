defmodule Komplen.Complaints.Complaint do
  use Ecto.Schema
  import Ecto.Changeset

  schema "complaints" do
    field :body, :string
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(complaint, attrs) do
    complaint
    |> cast(attrs, [:title, :body])
    |> validate_required([:title, :body])
  end
end

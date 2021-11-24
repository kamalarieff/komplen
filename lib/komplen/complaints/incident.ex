defmodule Komplen.Complaints.Incident do
  use Ecto.Schema
  import Ecto.Changeset

  schema "incidents" do
    field :title, :string
    belongs_to :user, Komplen.Accounts.User
    belongs_to :complaint, Komplen.Complaints.Complaint

    timestamps()
  end

  @doc false
  def changeset(incident, attrs) do
    incident
    |> cast(attrs, [:title, :user_id, :complaint_id])
    |> validate_required([:title])
    # |> foreign_key_constraint(:user_id)
    # |> foreign_key_constraint(:complaint_id)
    |> assoc_constraint(:user)
    |> assoc_constraint(:complaint)
    # |> unique_constraint(:unique_user_incident, name: :unique_user_incident)
  end
end

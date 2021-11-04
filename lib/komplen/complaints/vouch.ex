defmodule Komplen.Complaints.Vouch do
  use Ecto.Schema
  import Ecto.Changeset

  alias Komplen.Accounts.User
  alias Komplen.Complaints.Complaint

  schema "vouches" do
    belongs_to :user, User
    belongs_to :complaint, Complaint

    timestamps()
  end

  @doc """
  Changeset for vouches. More constraints are set on the database layer.

  Returns `:ok`.

  ## Examples

      iex> Komplen.Complaints.Vouch.changeset(%Vouch{user_id: 1, complaint_id: 1})
      :ok

  """
  def changeset(vouch, attrs) do
    vouch
    |> cast(attrs, [:user_id, :complaint_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:complaint_id)
  end
end

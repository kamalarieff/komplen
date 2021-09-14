defmodule Komplen.Accounts.Admin do
  use Ecto.Schema
  import Ecto.Changeset

  alias Komplen.Accounts.User

  schema "admins" do
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(admin, attrs) do
    admin
    |> cast(attrs, [])
    |> validate_required([:user_id])
    |> Ecto.Changeset.assoc_constraint(:user)
  end
end

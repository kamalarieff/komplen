defmodule Komplen.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Komplen.Accounts.{Admin,Profile}

  schema "users" do
    field :username, :string
    has_one :admin, Admin
    has_one :profile, Profile

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username])
    |> validate_required([:username])
    |> unique_constraint(:username)
  end
end

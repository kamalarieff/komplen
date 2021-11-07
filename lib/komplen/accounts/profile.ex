defmodule Komplen.Accounts.Profile do
  use Ecto.Schema
  import Ecto.Changeset

  alias Komplen.Accounts.User

  schema "profiles" do
    field :phone, :string
    field :email, :string
    field :name, :string
    field :ic_number, :string
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(profile, attrs) do
    profile
    |> cast(attrs, [:phone, :email, :name, :ic_number])
    |> validate_required([:phone, :email, :name, :ic_number])
    |> foreign_key_constraint(:user_id)
  end
end

defmodule Komplen.Repo.Migrations.CreateProfiles do
  use Ecto.Migration

  def change do
    create table(:profiles) do
      add :phone, :string
      add :email, :string
      add :name, :string
      add :ic_number, :string
      add :user_id, references(:users, [on_delete: :nothing, validate: true])

      timestamps()
    end
  end
end

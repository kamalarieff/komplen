defmodule Komplen.Repo.Migrations.CreateAdmins do
  use Ecto.Migration

  def change do
    create table(:admins) do
      add :user_id, references(:users, [on_delete: :nothing, validate: true])

      timestamps()
    end

    create unique_index(:admins, [:user_id])
  end
end

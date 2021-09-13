defmodule Komplen.Repo.Migrations.CreateAdmins do
  use Ecto.Migration

  def change do
    create table(:admins) do
      add :admin_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:admins, [:admin_id])
  end
end

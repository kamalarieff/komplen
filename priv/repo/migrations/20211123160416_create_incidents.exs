defmodule Komplen.Repo.Migrations.CreateIncidents do
  use Ecto.Migration

  def change do
    create table(:incidents) do
      add :title, :text
      add :user_id, references(:users, [on_delete: :nothing, validate: true]), null: false
      add :complaint_id, references(:complaints, [on_delete: :nothing, validate: true]), null: false

      timestamps()
    end

    create index(:incidents, [:user_id])
    create index(:incidents, [:complaint_id])
  end
end

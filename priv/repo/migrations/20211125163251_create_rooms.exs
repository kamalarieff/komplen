defmodule Komplen.Repo.Migrations.CreateRooms do
  use Ecto.Migration

  def change do
    create table(:rooms) do
      # Maybe this will come in handy
      # add :created_user_id, references(:users, on_delete: :nothing)
      add :complaint_id, references(:complaints, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:rooms, [:complaint_id])
  end
end

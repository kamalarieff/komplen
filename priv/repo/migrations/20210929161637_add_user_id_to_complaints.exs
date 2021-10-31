defmodule Komplen.Repo.Migrations.AddUserIdToComplaints do
  use Ecto.Migration

  def change do
    alter table(:complaints) do
      add :user_id, references(:users, [on_delete: :nothing, validate: true])
    end
  end
end

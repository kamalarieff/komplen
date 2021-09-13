defmodule Komplen.Repo.Migrations.AddUserIdToAdmin do
  use Ecto.Migration

  def change do
    alter table(:admins) do
      add :user_id, references(:users, on_delete: :nothing)
    end
  end
end

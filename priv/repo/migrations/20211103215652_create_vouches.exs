defmodule Komplen.Repo.Migrations.CreateVouches do
  use Ecto.Migration

  def change do
    create table(:vouches) do
      # This is how you add options to this macro
      # https://elixirforum.com/t/can-you-modify-a-columns-references-3-options-in-ecto/4443
      add :complaint_id, references(:complaints, on_delete: :nothing), null: false
      add :user_id, references(:users, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:vouches, [:complaint_id])
    create index(:vouches, [:user_id])
  end
end

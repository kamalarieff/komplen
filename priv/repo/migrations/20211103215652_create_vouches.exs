defmodule Komplen.Repo.Migrations.CreateVouches do
  use Ecto.Migration

  def change do
    create table(:vouches) do
      # YOGHIRT: This is how you add options to this macro
      # https://elixirforum.com/t/can-you-modify-a-columns-references-3-options-in-ecto/4443
      add :complaint_id, references(:complaints, on_delete: :nothing), null: false
      add :user_id, references(:users, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:vouches, [:complaint_id])
    create index(:vouches, [:user_id])
    # YOGHIRT: This is how to create unique constraint
    # you need to add something to the changeset as well
    # https://stackoverflow.com/questions/36418223/creating-a-unique-constraint-on-two-columns-together-in-ecto
    create unique_index(:vouches, [:complaint_id, :user_id], name: :unique_user_complaint)
  end
end

defmodule Komplen.Repo.Migrations.CreateComplaints do
  use Ecto.Migration

  def change do
    create table(:complaints) do
      add :title, :string
      add :body, :text
      add :lat, :text
      add :lng, :text

      timestamps()
    end

  end
end

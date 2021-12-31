defmodule Komplen.Repo.Migrations.CreateComplaints do
  use Ecto.Migration

  def change do
    create table(:complaints) do
      add :title, :string
      add :body, :text
      add :lat, :text
      add :lng, :text
      # YOGHIRT
      # this type syntax can be found here https://hexdocs.pm/ecto/Ecto.Schema.html#module-types-and-casting
      add :photo_urls, {:array, :string}, default: []

      timestamps()
    end

  end
end

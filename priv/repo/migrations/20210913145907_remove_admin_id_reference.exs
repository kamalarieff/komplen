defmodule Komplen.Repo.Migrations.RemoveAdminIdReference do
  use Ecto.Migration

  def up do
    alter table(:admins) do
      modify(:admin_id, :bigint, null: true)
    end

    drop constraint(:admins, "admins_admin_id_fkey")
  end

  def down do
    alter table(:admins) do
      modify(:admin_id, references(:references), null: false)
    end
  end
end

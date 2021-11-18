defmodule Komplen.Repo.Migrations.AddStatusToComplaints do
  use Ecto.Migration

  def change do
    alter table(:complaints) do
      add :status, :string, default: "new"
    end
    
    create constraint("complaints",
                      :allowed_status, 
                      check: "status in ('new', 'in progress', 'done')")
  end
end

defmodule TaskManager.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :title, :string
      add :description, :string
      add :status, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:tasks, [:title])
    create index(:tasks, [:status])
  end
end

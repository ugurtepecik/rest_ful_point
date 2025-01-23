defmodule RestFulPoint.Repo.Migrations.CreateFolders do
  @moduledoc false

  use Ecto.Migration

  @table :folders

  def up do
    create table(@table) do
      add :name, :string, size: 256, null: false
      add :collection_id, references(:collections, type: :binary_id), null: false
      add :master_folder_id, references(:folders, type: :binary_id), null: true
      add :deleted_at, :utc_datetime_usec, null: true

      timestamps(type: :utc_datetime_usec)
    end

    create index(@table, [:deleted_at])
  end

  def down do
    drop table(@table)
  end
end

defmodule RestFulPoint.Repo.Migrations.CreateRequests do
  @moduledoc false

  use Ecto.Migration

  @table :requests

  def up do
    create table(@table) do
      add :name, :string, size: 256, null: falsemix
      add :folder_id, references(:folders, type: :binary_id), null: true
      add :deleted_at, :utc_datetime_usec, null: true

      timestamps(type: :utc_datetime_usec)
    end

    create index(@table, [:deleted_at])
  end

  def down do
    drop table(@table)
  end
end

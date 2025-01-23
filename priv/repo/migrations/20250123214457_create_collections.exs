defmodule RestFulPoint.Repo.Migrations.CreateCollections do
  @moduledoc false

  use Ecto.Migration

  @table :collections

  def up do
    create table(@table) do
      add :name, :string, size: 256, null: false

      add :deleted_at, :utc_datetime_usec, null: true

      timestamps(type: :utc_datetime_usec)
    end

    create index(@table, [:deleted_at])
  end

  def down do
    drop table(@table)
  end
end

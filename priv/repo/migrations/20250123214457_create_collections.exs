defmodule RestFulPoint.Repo.Migrations.CreateCollections do
  @moduledoc false

  use Ecto.Migration

  import RestFulPoint.Shareds.MigrationHelpers,
    only: [
      add_soft_delete_and_timestamps: 0,
      drop_functions: 1,
      drop_soft_delete_trigger: 1,
      get_soft_delete_trigger_name: 1,
      get_soft_delete_wrapper_function_name: 1,
      upsert_soft_delete_trigger_function: 3,
      upsert_soft_delete_trigger: 2
    ]

  @table :collections

  def up do
    create table(@table) do
      add :name, :string, size: 256, null: false

      add_soft_delete_and_timestamps()
    end

    create index(@table, [:deleted_at])

    upsert_soft_delete_trigger_function(
      @table,
      :propagate_collection_deleted_at,
      :collection_id
    )

    upsert_soft_delete_trigger(
      @table,
      [:propagate_collection_deleted_at]
    )
  end

  def down do
    drop_soft_delete_trigger(@table)
    drop_functions([:propagate_collection_deleted_at])

    drop table(@table)
  end
end

defmodule RestFulPoint.Repo.Migrations.CreateFolders do
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

  @table :folders

  def up do
    create table(@table) do
      add :name, :string, size: 256, null: false
      add :collection_id, references(:collections, type: :binary_id), null: true
      add :base_folder_id, references(:folders, type: :binary_id), null: true

      add_soft_delete_and_timestamps()
    end

    create index(@table, [:deleted_at])

    execute """
    ALTER TABLE #{@table}
    ADD CONSTRAINT collection_or_base_folder_not_null
    CHECK (
      (collection_id IS NOT NULL AND base_folder_id IS NULL) OR
      (collection_id IS NULL AND base_folder_id IS NOT NULL)
    )
    """

    upsert_soft_delete_trigger_function(
      @table,
      :propagate_folder_deleted_at,
      :folder_id
    )

    upsert_soft_delete_trigger_function(
      @table,
      :propagate_base_folder_deleted_at,
      :base_folder_id
    )

    upsert_soft_delete_trigger(
      @table,
      [:propagate_folder_deleted_at, :propagate_base_folder_deleted_at]
    )
  end

  def down do
    drop_soft_delete_trigger(@table)
    drop_functions([:propagate_folder_deleted_at, :propagate_base_folder_deleted_at])

    drop table(@table)
  end
end

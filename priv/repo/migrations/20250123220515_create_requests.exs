defmodule RestFulPoint.Repo.Migrations.CreateRequests do
  @moduledoc false

  use Ecto.Migration

  import RestFulPoint.Shareds.MigrationHelpers

  @table :requests

  def up do
    enums = [:delete, :get, :head, :options, :patch, :post, :put]

    create_enum(:method_enum, enums)

    create table(@table) do
      add :name, :string, size: 256, null: false
      add :collection_id, references(:collections, type: :binary_id), null: true
      add :folder_id, references(:folders, type: :binary_id), null: true
      add :method, MethodEnum.type(), null: false
      add :url, :string, null: true
      add :headers, :map, null: true
      add :query_params, :map, null: true
      add :path_params, :map, null: true
      add :body, :map, null: true

      add_soft_delete_and_timestamps()
    end

    create index(@table, [:deleted_at])

    execute """
    ALTER TABLE #{@table}
    ADD CONSTRAINT collection_or_folder_not_null
    CHECK (
      (collection_id IS NOT NULL AND folder_id IS NULL) OR
      (collection_id IS NULL AND folder_id IS NOT NULL)
    )
    """

    upsert_soft_delete_trigger_function(
      @table,
      :propagate_request_deleted_at,
      :request_id
    )

    upsert_soft_delete_trigger(
      @table,
      [:propagate_request_deleted_at]
    )
  end

  def down do
    drop_soft_delete_trigger(@table)
    drop_functions([:propagate_request_deleted_at])

    drop table(@table)

    MethodEnum.drop_type()
  end
end

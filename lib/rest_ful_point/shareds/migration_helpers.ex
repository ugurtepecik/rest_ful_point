defmodule RestFulPoint.Shareds.MigrationHelpers do
  @moduledoc """
  Provides reusable macros for Ecto migrations.
  """

  defmacro add_soft_delete_and_timestamps do
    quote do
      add :deleted_at, :utc_datetime_usec, null: true
      timestamps(type: :utc_datetime_usec)
    end
  end

  defmacro upsert_soft_delete_trigger_function(table_name, function_name, foreign_key_name) do
    quote do
      parent_table = unquote(table_name)
      function_name = unquote(function_name)
      foreign_key_name = unquote(foreign_key_name)

      execute """
      CREATE OR REPLACE FUNCTION #{unquote(function_name)}(
        parent_id UUID,
        deleted_at TIMESTAMP
      )
      RETURNS VOID AS $$
      DECLARE
        child_table_name TEXT;
        query TEXT;
      BEGIN
        -- Iterate over child tables with a foreign key referencing the parent table
        FOR child_table_name IN
          SELECT
            c.relname AS table_name
          FROM
            pg_constraint AS con
            JOIN pg_class AS c ON con.conrelid = c.oid
            JOIN pg_attribute AS a ON a.attnum = ANY(con.conkey)
          WHERE
            con.confrelid = (SELECT oid FROM pg_class WHERE relname = '#{parent_table}')
            AND a.attname = '#{foreign_key_name}'
        LOOP
          -- Check if the child table has a 'deleted_at' column AND the foreign key exists
          IF EXISTS (
            SELECT 1
            FROM information_schema.columns
            WHERE table_name = child_table_name
              AND column_name = 'deleted_at'
          ) AND EXISTS (
            SELECT 1
            FROM information_schema.columns
            WHERE table_name = child_table_name
              AND column_name = '#{foreign_key_name}'
          ) THEN
            -- Update the 'deleted_at' column for rows matching the parent_id
            query := format(
              'UPDATE %I SET deleted_at = $1 WHERE #{foreign_key_name} = $2',
              child_table_name
            );
            EXECUTE query USING deleted_at, parent_id;
          END IF;
        END LOOP;
      END;
      $$ LANGUAGE plpgsql;
      """
    end
  end

  defmacro upsert_soft_delete_trigger(table_name, function_names) do
    quote do
      table_name = unquote(table_name)
      function_names = unquote(function_names)
      trigger_name = get_soft_delete_trigger_name(table_name)
      wrapper_function_name = "#{get_soft_delete_wrapper_function_name(table_name)}()"

      execute "DROP TRIGGER IF EXISTS #{trigger_name} ON #{table_name};"

      execute """
      CREATE OR REPLACE FUNCTION #{wrapper_function_name}
      RETURNS TRIGGER AS $$
      BEGIN

      #{Enum.reduce(function_names, "", fn function_name, acc -> "PERFORM #{function_name}(NEW.id, NEW.deleted_at);" end)}

      RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
      """

      execute """
      CREATE TRIGGER #{trigger_name}
      AFTER UPDATE OF deleted_at ON #{table_name}
      FOR EACH ROW
      EXECUTE FUNCTION #{wrapper_function_name};
      """
    end
  end

  defmacro drop_soft_delete_trigger(table_name) do
    quote do
      table_name = unquote(table_name)
      trigger_name = get_soft_delete_trigger_name(table_name)
      function_name = "#{get_soft_delete_wrapper_function_name(table_name)}"

      execute "DROP TRIGGER IF EXISTS #{trigger_name} ON #{table_name};"
      drop_functions([function_name])
    end
  end

  defmacro drop_functions(function_names) do
    quote do
      function_names = unquote(function_names)

      Enum.each(function_names, fn function_name ->
        execute "DROP FUNCTION IF EXISTS #{function_name}();"
      end)
    end
  end

  defmacro get_soft_delete_trigger_name(table_name) do
    quote do
      "trigger_#{unquote(table_name)}_soft_delete"
    end
  end

  defmacro get_soft_delete_wrapper_function_name(table_name) do
    quote do
      "#{unquote(table_name)}_soft_delete_function"
    end
  end
end

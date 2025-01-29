defmodule RestFulPoint.Queries.Collection do
  @moduledoc false

  import Ecto.Query

  alias Ecto.Changeset
  alias Ecto.Query
  alias Ecto.UUID
  alias RestFulPoint.Models.Collection

  @type filters :: [{:id, UUID.t()}]

  @type preload_option ::
          atom()
          | {atom(), Query.t() | keyword() | (Query.t() -> Query.t())}
          | {atom(), [preload_option]}

  @type opts :: [preload: preload_option | [preload_option]]

  @spec prepare_insert(map()) :: Changeset.t()
  def prepare_insert(changes) do
    Collection.create(changes)
  end

  @spec prepare_update(Collection.t(), map()) :: Changeset.t()
  def prepare_update(%Collection{} = collection, changes) do
    updateable_changes = Map.take(changes, Collection.updateable_fields())

    Collection.update(collection, updateable_changes)
  end

  @spec update_query(filters(), map(), opts()) :: Query.t()
  @spec update_query(filters(), map()) :: Query.t()
  def update_query(filters, changes, opts \\ []) do
    updateable_changes =
      changes
      |> Map.take(Collection.updateable_fields())
      |> Utils.convert_to_keyword_list()

    filters
    |> filter(opts)
    |> update(set: ^updateable_changes)
  end

  @spec filter(filters(), opts()) :: Query.t()
  @spec filter(filters()) :: Query.t()
  def filter(filters, opts \\ []) do
    deleteds? = Keyword.get(opts, :deleteds?, false)

    Collection
    |> from(as: :collection)
    |> where(^filter_where(filters))
    |> maybe_deleteds(Keyword.get(filters, :deleted_at, deleteds?))
    |> maybe_preload(Keyword.get(opts, :preload))
    |> maybe_select(Keyword.get(opts, :select))
  end

  @spec filter_where(filters()) :: Macro.t()
  defp filter_where(filters) do
    Enum.reduce(filters, dynamic(true), &apply_filter/2)
  end

  defp apply_filter({:id, id}, dynamic) do
    dynamic([collection: c], ^dynamic and c.id == ^id)
  end

  @spec maybe_deleteds(Query.t(), boolean()) :: Query.t()
  defp maybe_deleteds(query, false) do
    where(query, [collection: c], is_nil(c.deleted_at))
  end

  defp maybe_deleteds(query, true), do: query

  @spec maybe_preload(Query.t(), preload_option | [preload_option] | nil) :: Query.t()
  defp maybe_preload(query, nil), do: query

  defp maybe_preload(query, preloads) when is_list(preloads) do
    Enum.reduce(preloads, query, &apply_preload/2)
  end

  defp maybe_preload(query, preload), do: apply_preload(preload, query)

  @spec maybe_select(Query.t(), boolean() | [atom()] | nil) :: Query.t()
  def maybe_select(query, true), do: select(query, [collection: c], c)

  def maybe_select(query, fields) when is_list(fields), do: select(query, ^fields)

  def maybe_select(query, _fields), do: query

  @spec apply_preload(preload_option(), Query.t()) :: Query.t()
  defp apply_preload(assoc, query) when is_atom(assoc) do
    preload(query, ^assoc)
  end

  defp apply_preload({assoc, preload_query}, query) when is_function(preload_query, 1) do
    preload(query, [{^assoc, ^preload_query}])
  end

  defp apply_preload({assoc, preload_opts}, query) when is_list(preload_opts) do
    if Keyword.keyword?(preload_opts) do
      preload(query, [{^assoc, ^preload_opts}])
    else
      preload(query, [{^assoc, ^build_nested_preload(preload_opts)}])
    end
  end

  @spec build_nested_preload(maybe_improper_list()) :: any()
  defp build_nested_preload(preloads) when is_list(preloads) do
    Enum.map(preloads, fn
      {assoc, nested_preloads} when is_list(nested_preloads) ->
        {assoc, build_nested_preload(nested_preloads)}

      {assoc, preload_fun} when is_function(preload_fun, 1) ->
        {assoc, preload_fun}

      assoc when is_atom(assoc) ->
        assoc
    end)
  end
end

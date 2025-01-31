defmodule RestFulPoint.Models.Request do
  @moduledoc false

  use BaseSchema,
    required_fields: ~w(name method url)a,
    optional_fields: ~w(collection_id folder_id headers query_params path_params body deleted_at)a

  alias RestFulPoint.Models.Collection
  alias RestFulPoint.Models.Folder

  @derive {Jason.Encoder, only: @fields -- [:deleted_at]}

  typed_schema "requests" do
    field :name, :string
    field :deleted_at, :utc_datetime_usec
    field :method, MethodEnum
    field :url, :string
    field :headers, :map
    field :query_params, :map
    field :path_params, :map
    field :body, :map

    belongs_to :collection, Collection
    belongs_to :folder, Folder

    has_many :folders, __MODULE__

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(collection, attrs) do
    collection
    |> super(attrs)
    |> foreign_key_constraint(:collection_id)
    |> foreign_key_constraint(:folder_id)
    |> validate_length(:name, max: 256)
    |> validate_collection_or_folder()
  end

  @spec create(map()) :: Ecto.Changeset.t()
  def create(model), do: BaseSchema.create(model)

  @spec validate_collection_or_folder(Changeset.t()) :: Changeset.t()
  defp validate_collection_or_folder(changeset) do
    collection_id = get_field(changeset, :collection_id)
    folder_id = get_field(changeset, :folder_id)

    cond do
      is_nil(collection_id) and is_nil(folder_id) ->
        add_error(
          changeset,
          :base,
          "Either collection_id or folder_id must be present."
        )

      not is_nil(collection_id) and not is_nil(folder_id) ->
        add_error(
          changeset,
          :base,
          "Only one of collection_id or folder_id can be present."
        )

      true ->
        changeset
    end
  end
end

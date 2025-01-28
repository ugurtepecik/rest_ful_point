defmodule RestFulPoint.Models.Collection do
  @moduledoc false

  use BaseSchema,
    required_fields: ~w(name)a,
    optional_fields: ~w(deleted_at)a

  @derive {Jason.Encoder, only: @fields -- [:deleted_at]}

  typed_schema "collections" do
    field :name, :string

    field :deleted_at, :utc_datetime_usec

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(collection, attrs) do
    collection |> super(attrs) |> validate_length(:name, max: 256)
  end

  @spec create(map()) :: Ecto.Changeset.t()
  def create(model), do: BaseSchema.create(model)
end

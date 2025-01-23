defmodule RestFulPoint.Models.Collection do
  @moduledoc false

  use BaseModel,
    required_fields: ~w(name)a,
    optional_fields: ~w(deleted_at)a

  typed_schema "collections" do
    field :name, :string

    field :deleted_at, :utc_datetime_usec

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(collection, attrs) do
    collection |> super(attrs) |> validate_length(:name, max: 256)
  end

  @spec create(map()) :: Ecto.Changeset.t()
  def create(model), do: BaseModel.create(model)
end

defmodule BaseSchema do
  @moduledoc false

  defmacro __using__(opts) do
    required_fields = Keyword.fetch!(opts, :required_fields)
    optional_fields = Keyword.fetch!(opts, :optional_fields)
    updateable_fields = Keyword.get(opts, :updateable_fields, [])

    quote do
      use Ecto.Schema
      use TypedEctoSchema

      import Ecto.Changeset

      alias Ecto.Changeset

      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id

      @required_fields unquote(required_fields)
      @optional_fields unquote(optional_fields)
      @updateable_fields unquote(updateable_fields)
      @fields unquote(required_fields) ++ unquote(optional_fields)

      @spec changeset(map(), map()) :: Changeset.t()
      def changeset(model, attrs) do
        model
        |> cast(attrs, @required_fields ++ @optional_fields)
        |> validate_required(@required_fields)
      end

      @spec update(model :: Changeset.t(), changes :: map()) :: Changeset.t()
      def update(model, changes), do: changeset(model, changes)

      @spec updateable_fields(type :: :atom | :string) :: list()
      @spec updateable_fields() :: list()
      def updateable_fields(type \\ :atom)

      def updateable_fields(:atom), do: @updateable_fields

      def updateable_fields(:string), do: Enum.map(@updateable_fields, &to_string/1)

      defoverridable changeset: 2, update: 2
    end
  end

  defmacro create(model) do
    quote do
      __MODULE__.changeset(%__MODULE__{}, unquote(model))
    end
  end
end

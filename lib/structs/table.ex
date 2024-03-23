defmodule ExDbml.Structs.Table do
  alias ExDbml.Structs.TableColumn
  alias ExDbml.Structs.TableIndex
  alias ExDbml.Structs.TableSettings

  @enforce_keys [:name, :columns]
  defstruct [:schema, :name, :alias, :settings, :columns, :note, indexes: []]

  @schema [
    schema: [
      type: :string,
      required: false
    ],
    name: [
      type: :string,
      required: true
    ],
    alias: [
      type: :string,
      required: false
    ],
    settings: [
      type: {:custom, TableSettings, :new, []},
      required: false
    ],
    columns: [
      type: {:list, {:custom, TableColumn, :new, []}},
      required: true
    ],
    indexes: [
      type: {:list, {:custom, TableIndex, :new, []}},
      required: false,
      default: []
    ],
    note: [
      type: :string,
      required: false
    ]
  ]

  @spec new(keyword()) :: {:ok, %__MODULE__{}} | {:error, NimbleOptions.ValidationError.t()}
  def new(attrs) when is_list(attrs) do
    with updated_attrs <- merge_columns_and_indexes(attrs),
         {:ok, validated_attrs} <- NimbleOptions.validate(updated_attrs, @schema) do
      {:ok, struct!(__MODULE__, Enum.into(validated_attrs, %{}))}
    end
  end

  defp merge_columns_and_indexes(attrs) do
    attrs
    |> Keyword.put(:columns, merge_by_key(attrs, :columns))
    |> Keyword.put(:indexes, merge_by_key(attrs, :indexes))
  end

  defp merge_by_key(attrs, key) when is_atom(key) do
    attrs
    |> Enum.filter(fn {k, _} -> k == key end)
    |> Enum.flat_map(fn {_k, value} -> value end)
  end
end

defmodule ExDbml.Structs.TableColumnSettings do
  alias ExDbml.Structs.InlineRelationship

  defstruct [
    :note,
    :default,
    :pk,
    :primary_key,
    :null,
    :not_null,
    unique: false,
    increment: false,
    relationships: []
  ]

  # TODO: validate and remove duplicate attributes
  @schema [
    note: [
      type: :string,
      required: false
    ],
    default: [
      type: {:or, [:string, :integer, :float, :boolean, nil]},
      required: false
    ],
    pk: [
      type: :boolean,
      required: false
    ],
    primary_key: [
      type: :boolean,
      required: false
    ],
    null: [
      type: :boolean,
      required: false
    ],
    not_null: [
      type: :boolean,
      required: false
    ],
    unique: [
      type: :boolean,
      required: false,
      default: false
    ],
    increment: [
      type: :boolean,
      required: false,
      default: false
    ],
    relationships: [
      type: {:list, {:custom, InlineRelationship, :new, []}},
      required: false,
      default: []
    ]
  ]

  @spec new(keyword()) :: {:ok, %__MODULE__{}} | {:error, NimbleOptions.ValidationError.t()}
  def new(attrs) when is_list(attrs) do
    with updated_attrs <- merge_relationships(attrs),
         {:ok, validated_attrs} <- NimbleOptions.validate(updated_attrs, @schema) do
      {:ok, struct!(__MODULE__, Enum.into(validated_attrs, %{}))}
    end
  end

  defp merge_relationships(attrs) do
    attrs
    |> Keyword.put(:relationships, merge_by_key(attrs, :relationships))
  end

  defp merge_by_key(attrs, key) when is_atom(key) do
    attrs
    |> Enum.filter(fn {k, _} -> k == key end)
    |> Enum.flat_map(fn {_k, value} -> value end)
  end
end

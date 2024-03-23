defmodule ExDbml.Structs.InlineRelationship do
  alias ExDbml.Structs.RelationshipTable

  @enforce_keys [:relationship_type, :target]
  defstruct [:relationship_type, :target]

  @schema [
    relationship_type: [
      type: {:in, [:one_to_many, :many_to_many, :many_to_one, :one_to_one]},
      required: true
    ],
    target: [
      type: {:custom, RelationshipTable, :new, []},
      required: true
    ]
  ]

  @spec new(keyword()) :: {:ok, %__MODULE__{}} | {:error, NimbleOptions.ValidationError.t()}
  def new(attrs) when is_list(attrs) do
    with {:ok, validated_attrs} <- NimbleOptions.validate(attrs, @schema) do
      {:ok, struct!(__MODULE__, Enum.into(validated_attrs, %{}))}
    end
  end
end

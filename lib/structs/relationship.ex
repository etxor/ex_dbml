defmodule ExDbml.Structs.Relationship do
  alias ExDbml.Structs.RelationshipSettings
  alias ExDbml.Structs.RelationshipTable

  @enforce_keys [:source, :relationship_type, :target]
  defstruct [:name, :source, :relationship_type, :target, :settings]

  @schema [
    name: [
      type: :string,
      required: false
    ],
    source: [
      type: {:custom, RelationshipTable, :new, []},
      required: true
    ],
    relationship_type: [
      type: {:in, [:one_to_many, :many_to_many, :many_to_one, :one_to_one]},
      required: true
    ],
    target: [
      type: {:custom, RelationshipTable, :new, []},
      required: true
    ],
    settings: [
      type: {:custom, RelationshipSettings, :new, []},
      required: false
    ]
  ]

  @spec new(keyword()) :: {:ok, %__MODULE__{}} | {:error, NimbleOptions.ValidationError.t()}
  def new(attrs) when is_list(attrs) do
    with {:ok, validated_attrs} <- NimbleOptions.validate(attrs, @schema) do
      {:ok, struct!(__MODULE__, Enum.into(validated_attrs, %{}))}
    end
  end
end

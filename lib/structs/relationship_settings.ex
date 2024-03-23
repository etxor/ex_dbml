defmodule ExDbml.Structs.RelationshipSettings do
  defstruct [:on_delete, :on_update]

  @schema [
    on_delete: [
      type: {:in, [:cascade, :restrict, :set_null, :set_default]},
      required: false
    ],
    on_update: [
      type: {:in, [:cascade, :restrict, :set_null, :set_default]},
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

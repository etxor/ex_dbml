defmodule ExDbml.Structs.Enum do
  alias ExDbml.Structs.EnumValue

  @enforce_keys [:name, :values]
  defstruct [:schema, :name, :values]

  @schema [
    schema: [
      type: :string,
      required: false
    ],
    name: [
      type: :string,
      required: true
    ],
    values: [
      type: {:list, {:custom, EnumValue, :new, []}},
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

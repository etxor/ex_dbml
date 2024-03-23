defmodule ExDbml.Structs.TableColumnType do
  @enforce_keys [:name]
  defstruct [:name, params: []]

  @schema [
    name: [
      type: :string,
      required: true
    ],
    params: [
      type: {:list, {:or, [:string, :integer, :float, :boolean, nil]}},
      required: false,
      default: []
    ]
  ]

  @spec new(keyword()) :: {:ok, %__MODULE__{}} | {:error, NimbleOptions.ValidationError.t()}
  def new(attrs) when is_list(attrs) do
    with {:ok, validated_attrs} <- NimbleOptions.validate(attrs, @schema) do
      {:ok, struct!(__MODULE__, Enum.into(validated_attrs, %{}))}
    end
  end
end

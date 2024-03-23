defmodule ExDbml.Structs.TableGroup do
  alias ExDbml.Structs.TableGroupTable

  @enforce_keys [:name, :tables]
  defstruct [:name, :tables]

  @schema [
    name: [
      type: :string,
      required: true
    ],
    tables: [
      type: {:list, {:custom, TableGroupTable, :new, []}},
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

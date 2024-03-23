defmodule ExDbml.Structs.TableColumn do
  alias ExDbml.Structs.TableColumnSettings
  alias ExDbml.Structs.TableColumnType

  @enforce_keys [:name, :type]
  defstruct [:name, :type, :settings]

  @schema [
    name: [
      type: :string,
      required: true
    ],
    type: [
      type: {:custom, TableColumnType, :new, []},
      required: true
    ],
    settings: [
      type: {:custom, TableColumnSettings, :new, []},
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

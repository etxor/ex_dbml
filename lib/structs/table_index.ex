defmodule ExDbml.Structs.TableIndex do
  alias ExDbml.Structs.TableIndexSettings

  @enforce_keys [:fields]
  defstruct [:fields, :settings]

  @schema [
    fields: [
      type: {:list, :string},
      required: true
    ],
    settings: [
      type: {:custom, TableIndexSettings, :new, []},
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

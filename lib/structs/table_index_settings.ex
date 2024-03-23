defmodule ExDbml.Structs.TableIndexSettings do
  defstruct [:name, :type, :note, pk: false, unique: false]

  @schema [
    name: [
      type: :string,
      required: false
    ],
    type: [
      type: {:in, ["hash", "btree"]},
      required: false
    ],
    pk: [
      type: :boolean,
      required: false,
      default: false
    ],
    unique: [
      type: :boolean,
      required: false,
      default: false
    ],
    note: [
      type: :string,
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

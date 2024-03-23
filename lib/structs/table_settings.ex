defmodule ExDbml.Structs.TableSettings do
  defstruct [:note, :headercolor]

  @schema [
    note: [
      type: :string,
      required: false
    ],
    # NOTE: validate hex color
    headercolor: [
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

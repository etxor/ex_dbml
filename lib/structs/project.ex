defmodule ExDbml.Structs.Project do
  alias ExDbml.Structs.CustomProperty

  defstruct [:name, :note, custom_properties: []]

  @schema [
    name: [
      type: :string,
      required: false
    ],
    note: [
      type: :string,
      required: false
    ],
    custom_properties: [
      type: {:list, {:custom, CustomProperty, :new, []}},
      required: false,
      default: []
    ]
  ]

  @spec new(keyword()) :: {:ok, %__MODULE__{}} | {:error, NimbleOptions.ValidationError.t()}
  def new(attrs) when is_list(attrs) do
    with updated_attrs <- Keyword.put(attrs, :custom_properties, merge_custom_properties(attrs)),
         {:ok, validated_attrs} <- NimbleOptions.validate(updated_attrs, @schema) do
      {:ok, struct!(__MODULE__, Enum.into(validated_attrs, %{}))}
    end
  end

  defp merge_custom_properties(attrs) do
    attrs
    |> Enum.filter(fn {key, _} -> key == :custom_properties end)
    |> Enum.flat_map(fn {_key, value} -> value end)
  end
end

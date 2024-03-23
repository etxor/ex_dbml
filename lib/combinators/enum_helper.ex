defmodule ExDbml.Combinators.EnumHelper do
  @moduledoc false
  import NimbleParsec
  import ExDbml.Combinators.Common.Dynamic
  alias ExDbml.Combinators.Common.Static

  @spec enum() :: NimbleParsec.t()
  def enum do
    type()
    |> optional(enum_schema())
    |> concat(enum_name())
    |> optional(enum_definition())
  end

  defp type, do: ignorecase("enum") |> replace(:enum) |> unwrap_and_tag(:type)

  defp enum_schema, do: unwrap_and_tag(parsec({Static, :schema}), :schema)

  defp enum_name, do: parsec({Static, :name}) |> unwrap_and_tag(:name)

  defp enum_definition do
    curly_brackets_block([
      [
        value() |> times(min: 1) |> tag(:values),
        # TODO: seems like this is not needed
        parsec({Static, :ignore_whitespace_and_comments})
      ]
      |> unordered_choice(min: 1)
    ])
  end

  defp value do
    optional(parsec({Static, :ignore_whitespace_and_comments}))
    |> unwrap_and_tag(parsec({Static, :name}), :name)
    |> optional(settings_block(parsec({Static, :inline_note}) |> unwrap_and_tag(:note)))
    |> wrap()
  end
end

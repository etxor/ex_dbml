defmodule ExDbml.Combinators.TableColumnHelper do
  @moduledoc false
  import ExDbml.Combinators.Common.Dynamic
  import NimbleParsec
  alias ExDbml.Combinators.Common.Static
  alias ExDbml.Combinators.Relationship

  @spec column() :: NimbleParsec.t()
  def column do
    column_name()
    |> concat(type())
    |> optional(settings())
    |> wrap()
  end

  defp column_name, do: parsec({Static, :name}) |> unwrap_and_tag(:name)

  defp type do
    choice([
      parsec({Static, :function}),
      parsec({Static, :schema})
      |> parsec({Static, :name})
      |> reduce({List, :to_string, []})
      |> unwrap_and_tag(:name),
      parsec({Static, :name}) |> unwrap_and_tag(:name)
    ])
    |> tag(:type)
  end

  defp settings do
    settings_block(
      choices: [
        parsec({Static, :inline_note}) |> unwrap_and_tag(:note),
        keyword("default") |> unwrap_and_tag(:default),
        ignorecase("pk") |> replace({:pk, true}),
        ignorecase_words(["primary", "key"]) |> replace({:primary_key, true}),
        ignorecase("unique") |> replace({:unique, true}),
        ignorecase("increment") |> replace({:increment, true}),
        ignorecase_words(["not", "null"]) |> replace({:not_null, true}),
        ignorecase("null") |> replace({:null, true}),
        parsec({Relationship, :parse_inline_relationship}) |> times(min: 1) |> tag(:relationships)
      ]
    )
    |> tag(:settings)
  end
end

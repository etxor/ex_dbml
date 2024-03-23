defmodule ExDbml.Combinators.TableIndexHelper do
  @moduledoc false
  import NimbleParsec
  import ExDbml.Combinators.Common.Dynamic
  alias ExDbml.Combinators.Common.Static

  @spec indexes() :: NimbleParsec.t()
  def indexes, do: type() |> concat(indexes_definition())

  defp type, do: ignore(ignorecase("indexes"))

  defp indexes_definition do
    curly_brackets_block([
      fields() |> optional(settings()) |> wrap() |> times(min: 1)
    ])
  end

  defp fields do
    optional(ignore(word("(")))
    |> times(field() |> optional(ignore(word(","))), min: 1)
    |> optional(ignore(word(")")))
    |> tag(:fields)
  end

  defp field, do: choice([parsec({Static, :name}), parsec({Static, :expression})])

  defp settings do
    settings_block(
      choices: [
        parsec({Static, :inline_note}) |> unwrap_and_tag(:note),
        string_keyword("name") |> unwrap_and_tag(:name),
        ignorecase("pk") |> replace({:pk, true}),
        ignorecase("unique") |> replace({:unique, true}),
        choice_keyword("type", ["hash", "btree"]) |> unwrap_and_tag(:type)
      ]
    )
    |> tag(:settings)
  end
end

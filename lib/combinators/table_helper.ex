defmodule ExDbml.Combinators.TableHelper do
  @moduledoc false
  import NimbleParsec
  import ExDbml.Combinators.Common.Dynamic
  alias ExDbml.Combinators.Common.Static
  alias ExDbml.Combinators.TableColumnHelper
  alias ExDbml.Combinators.TableIndexHelper

  @spec table() :: NimbleParsec.t()
  def table do
    table_type()
    |> choice([table_schema() |> concat(table_name()), table_name()])
    |> optional(table_alias())
    |> optional(table_settings())
    |> concat(table_definition())
  end

  defp table_type, do: ignorecase("table") |> replace(:table) |> unwrap_and_tag(:type)

  defp table_schema, do: unwrap_and_tag(parsec({Static, :schema}), :schema)

  defp table_name, do: unwrap_and_tag(parsec({Static, :name}), :name)

  defp table_alias do
    ignore(ignorecase("as")) |> concat(parsec({Static, :name})) |> unwrap_and_tag(:alias)
  end

  defp table_settings do
    settings_block(
      choices: [
        parsec({Static, :inline_note}) |> unwrap_and_tag(:note),
        hex_keyword("headercolor") |> unwrap_and_tag(:headercolor)
      ]
    )
    |> tag(:settings)
  end

  defp table_definition do
    curly_brackets_block([
      [
        TableColumnHelper.column() |> times(min: 1) |> tag(:columns),
        TableIndexHelper.indexes() |> tag(:indexes),
        parsec({Static, :note}) |> unwrap_and_tag(:note)
      ]
      |> unordered_choice(min: 0)
    ])
  end
end

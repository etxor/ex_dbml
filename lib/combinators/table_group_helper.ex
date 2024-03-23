defmodule ExDbml.Combinators.TableGroupHelper do
  @moduledoc false
  import ExDbml.Combinators.Common.Dynamic
  import NimbleParsec
  alias ExDbml.Combinators.Common.Static

  @spec table_group() :: NimbleParsec.t()
  def table_group do
    type()
    |> concat(table_group_name())
    |> concat(table_group_definition())
  end

  defp type, do: ignorecase("TableGroup") |> replace(:table_group) |> unwrap_and_tag(:type)

  defp table_group_name, do: parse_name()

  defp table_group_definition do
    curly_brackets_block([
      [
        parse_schema() |> concat(parse_name()) |> wrap(),
        parse_name() |> wrap()
      ]
      |> unordered_choice(min: 0)
    ])
    |> tag(:tables)
  end

  defp parse_schema, do: parsec({Static, :schema}) |> unwrap_and_tag(:schema)

  defp parse_name, do: parsec({Static, :name}) |> unwrap_and_tag(:name)
end

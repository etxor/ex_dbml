defmodule ExDbml.Combinators.RelationshipHelper do
  @moduledoc false
  import NimbleParsec
  import ExDbml.Combinators.Common.Dynamic
  alias ExDbml.Combinators.Common.Static

  @spec inline_relationship() :: NimbleParsec.t()
  def inline_relationship do
    ignore(keyword_key("ref"))
    |> concat(relationship_type())
    # TODO: allows composed FK, but inline relationships only support a single column
    |> concat(relationship_table() |> tag(:target))
    |> wrap()
  end

  @spec relationship() :: NimbleParsec.t()
  def relationship, do: choice([short_relationship(), long_relationship()]) |> wrap()

  defp long_relationship do
    type()
    |> optional(relationship_name())
    |> concat(long_relationship_definition())
  end

  defp long_relationship_definition do
    curly_brackets_block([
      relationship_table() |> tag(:source),
      relationship_type(),
      relationship_table() |> tag(:target),
      optional(settings())
    ])
  end

  defp short_relationship do
    type()
    |> optional(relationship_name())
    |> ignore(word(":"))
    |> concat(short_relationship_definition())
    |> optional(settings())
  end

  defp short_relationship_definition do
    tag(relationship_table(), :source)
    |> concat(relationship_type())
    |> tag(relationship_table(), :target)
  end

  defp type, do: ignorecase("ref") |> replace(:relationship) |> unwrap_and_tag(:type)

  defp relationship_name, do: parsec({Static, :name}) |> unwrap_and_tag(:name)

  defp relationship_table, do: choice([table_by_schema_and_name(), table_by_name()])

  defp table_by_schema_and_name do
    unwrap_and_tag(parsec({Static, :schema}), :schema)
    |> unwrap_and_tag(parsec({Static, :name}), :name)
    |> ignore(word("."))
    |> tag(columns(), :columns)
  end

  defp table_by_name do
    unwrap_and_tag(parsec({Static, :name}), :name)
    |> ignore(word("."))
    |> tag(columns(), :columns)
  end

  defp columns do
    choice([
      ignore(word("("))
      |> times(parsec({Static, :name}) |> optional(ignore(word(","))), min: 1)
      |> ignore(word(")")),
      parsec({Static, :name})
    ])
  end

  defp relationship_type do
    choice([
      replace(word("<>"), :many_to_many),
      replace(word("<"), :one_to_many),
      replace(word(">"), :many_to_one),
      replace(word("-"), :one_to_one)
    ])
    |> unwrap_and_tag(:relationship_type)
  end

  defp settings do
    choices = [
      ignore(keyword_key("on_delete")) |> concat(action_choices()) |> unwrap_and_tag(:on_delete),
      ignore(keyword_key("on_update")) |> concat(action_choices()) |> unwrap_and_tag(:on_update)
    ]

    settings_block(choices: choices) |> tag(:settings)
  end

  defp action_choices do
    choice([
      ignorecase("cascade") |> replace(:cascade),
      ignorecase("restrict") |> replace(:restrict),
      words(["set", "null"]) |> replace(:set_null),
      words(["set", "default"]) |> replace(:set_default),
      words(["no", "action"]) |> replace(:no_action)
    ])
  end
end

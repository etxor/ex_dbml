defmodule ExDbml.Parser do
  @moduledoc """
  This parser generates a Keyword list with tagged values from the DBML content.
  # TODO: return a list of structs instead of a keyword list
  """
  alias ExDbml.ParserHelper
  alias ExDbml.Structs.Project
  alias ExDbml.Structs.Table
  alias ExDbml.Structs.TableGroup
  alias ExDbml.Structs.Relationship
  alias ExDbml.Structs

  def parse_enums(dbml) do
    dbml
    |> ParserHelper.parse_enums()
    |> create_structs()
  end

  def parse_projects(dbml) do
    dbml
    |> ParserHelper.parse_projects()
    |> create_structs()
  end

  def parse_relationships(dbml) do
    dbml
    |> ParserHelper.parse_relationships()
    |> create_structs()
  end

  def parse_table_groups(dbml) do
    dbml
    |> ParserHelper.parse_table_groups()
    |> create_structs()
  end

  def parse_tables(dbml) do
    dbml
    |> ParserHelper.parse_tables()
    |> create_structs()
  end

  def parse(dbml) do
    dbml
    |> ParserHelper.parse()
    |> create_structs()
  end

  defp create_structs({:ok, matches, _rest, _context, _tuple, _integer}) do
    {:ok, Enum.map(matches, &cast/1)}
  end

  defp cast({:ok, match, _rest, _context, _tuple, _integer}) do
    cast(match)
  end

  defp cast(match) when is_list(match) do
    case Keyword.fetch(match, :type) do
      {:ok, :project} ->
        {:project, rest} = Keyword.pop!(match, :type)
        {:ok, project} = Project.new(rest)
        project

      {:ok, :enum} ->
        {:enum, rest} = Keyword.pop!(match, :type)
        {:ok, enum} = Structs.Enum.new(rest)
        enum

      {:ok, :relationship} ->
        {:relationship, rest} = Keyword.pop!(match, :type)
        {:ok, relationship} = Relationship.new(rest)
        relationship

      {:ok, :table_group} ->
        {:table_group, rest} = Keyword.pop!(match, :type)

        {:ok, table_group} = TableGroup.new(rest)
        table_group

      {:ok, :table} ->
        {:table, rest} = Keyword.pop!(match, :type)
        {:ok, table} = Table.new(rest)
        table
    end
  end

  defp cast(error), do: error
end

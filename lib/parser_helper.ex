defmodule ExDbml.ParserHelper do
  @moduledoc false
  import NimbleParsec
  alias ExDbml.Combinators
  alias ExDbml.Combinators.Common.Static

  defparsec :parse_enums,
            parsec({Combinators.Enum, :parse})
            |> times(min: 1)
            |> optional(parsec({Static, :ignore_whitespace_and_comments}))
            |> wrap()
            |> eos()

  defparsec :parse_projects,
            parsec({Combinators.Project, :parse})
            |> times(min: 1)
            |> optional(parsec({Static, :ignore_whitespace_and_comments}))
            |> wrap()
            |> eos()

  defparsec :parse_relationships,
            parsec({Combinators.Relationship, :parse})
            |> times(min: 1)
            |> optional(parsec({Static, :ignore_whitespace_and_comments}))
            # TODO: very likely that parse will requiere a wrap for this one
            |> eos()

  defparsec :parse_table_groups,
            parsec({Combinators.TableGroup, :parse})
            |> times(min: 1)
            |> optional(parsec({Static, :ignore_whitespace_and_comments}))
            |> wrap()
            |> eos()

  defparsec :parse_tables,
            parsec({Combinators.Table, :parse})
            |> times(min: 1)
            |> optional(parsec({Static, :ignore_whitespace_and_comments}))
            |> wrap()
            |> eos()

  defparsec :parse,
            choice([
              parsec({Combinators.Enum, :parse}) |> wrap(),
              parsec({Combinators.Project, :parse}) |> wrap(),
              parsec({Combinators.Relationship, :parse}),
              parsec({Combinators.TableGroup, :parse}) |> wrap(),
              parsec({Combinators.Table, :parse}) |> wrap()
            ])
            |> times(min: 1)
            |> optional(parsec({Static, :ignore_whitespace_and_comments}))
            |> eos()
end

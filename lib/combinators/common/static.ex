defmodule ExDbml.Combinators.Common.Static do
  @moduledoc false
  # NOTES:
  # - These combinators are meant to be used with `NimbleParsec.parsec/2`, in order to improve the
  #   compilation time of the modules.
  # - Tag the combinators from the caller to increase flexibility and reusability.
  # - Every combinator ignores whitespace and comments before the parsing starts to avoid spamming
  #   `ignore_whitespace_and_comments` in the caller.

  import NimbleParsec

  @alpha_ascii [?a..?z, ?A..?Z]
  @number_ascii [?0..?9]
  @alphanumeric_ascii @alpha_ascii ++ @number_ascii
  @whitespace_ascii [?\s, ?\t, ?\n, ?\r, ?\v, ?\f]

  defcombinator :schema,
                parsec(:name)
                |> optional(parsec(:ignore_whitespace_and_comments))
                |> ignore(string("."))

  defcombinator :function,
                unwrap_and_tag(parsec(:name), :name)
                |> optional(parsec(:ignore_whitespace_and_comments))
                |> ignore(string("("))
                |> optional(parsec(:function_params))
                |> optional(parsec(:ignore_whitespace_and_comments))
                |> ignore(string(")"))

  defcombinatorp :function_params,
                 times(
                   optional(parsec(:ignore_whitespace_and_comments))
                   |> choice([
                     integer(min: 1),
                     parsec(:name),
                     parsec(:dbml_string)
                   ])
                   |> optional(parsec(:ignore_whitespace_and_comments))
                   |> optional(ignore(string(","))),
                   min: 1
                 )
                 |> tag(:params)

  defcombinator :name,
                optional(parsec(:ignore_whitespace_and_comments))
                |> choice([
                  parsec(:name_starts_with_alpha),
                  parsec(:name_starts_with_number),
                  parsec(:name_in_double_quotes)
                ])
                |> label("name starting with a character or in double quotes")

  defcombinator :quoteless_name,
                optional(parsec(:ignore_whitespace_and_comments))
                |> choice([
                  parsec(:name_starts_with_alpha),
                  parsec(:name_starts_with_number)
                ])
                |> label("name starting with a character")

  defcombinatorp :name_starts_with_alpha,
                 ascii_char(@alpha_ascii ++ [?_, ?-])
                 |> optional(ascii_string(@alphanumeric_ascii ++ [?_, ?-], min: 1))
                 |> reduce({List, :to_string, []})
                 |> label("name starting with an alphabetic character or underscore")

  defcombinatorp :name_starts_with_number,
                 ascii_char(@number_ascii)
                 |> ascii_string(@alphanumeric_ascii ++ [?_, ?-], min: 1)
                 |> reduce({List, :to_string, []})
                 |> label("name starting with a number")

  defcombinatorp :name_in_double_quotes,
                 ignore(string(~S(")))
                 |> utf8_string([not: ?"], min: 1)
                 |> ignore(string(~S(")))
                 |> reduce({List, :to_string, []})
                 |> label("name in double quotes, allowing any character except double quotes")

  defcombinator :expression,
                optional(parsec(:ignore_whitespace_and_comments))
                |> ignore(string("`"))
                |> ascii_string(
                  @alphanumeric_ascii ++ @whitespace_ascii ++ [?_, ?(, ?), ?-, ?', ?*],
                  min: 1
                )
                |> ignore(string("`"))

  defcombinator :hex,
                optional(parsec(:ignore_whitespace_and_comments))
                |> string("#")
                |> ascii_string(@number_ascii ++ [?A..?F, ?a..?f], 6)
                |> reduce({List, :to_string, []})

  defcombinator :note, choice([parsec(:multi_line_note), parsec(:inline_note)])

  defcombinatorp :multi_line_note,
                 optional(parsec(:ignore_whitespace_and_comments))
                 |> ignore(choice([string("n"), string("N")]))
                 |> ignore(choice([string("o"), string("O")]))
                 |> ignore(choice([string("t"), string("T")]))
                 |> ignore(choice([string("e"), string("E")]))
                 |> optional(parsec(:ignore_whitespace_and_comments))
                 |> ignore(string("{"))
                 |> optional(parsec(:ignore_whitespace_and_comments))
                 |> parsec(:dbml_string)
                 |> optional(parsec(:ignore_whitespace_and_comments))
                 |> ignore(string("}"))

  defcombinator :inline_note,
                optional(parsec(:ignore_whitespace_and_comments))
                |> ignore(choice([string("n"), string("N")]))
                |> ignore(choice([string("o"), string("O")]))
                |> ignore(choice([string("t"), string("T")]))
                |> ignore(choice([string("e"), string("E")]))
                |> optional(parsec(:ignore_whitespace_and_comments))
                |> ignore(string(":"))
                |> parsec(:dbml_string)

  defcombinator :dbml_string,
                optional(parsec(:ignore_whitespace_and_comments))
                |> choice([parsec(:multi_line_dbml_string), parsec(:inline_dbml_string)])

  defcombinatorp :multi_line_dbml_string,
                 ignore(string("'''"))
                 |> repeat(utf8_char(not: ?'))
                 |> ignore(string("'''"))
                 |> reduce({List, :to_string, []})

  defcombinatorp :inline_dbml_string,
                 ignore(string("'"))
                 |> repeat(utf8_char(not: ?'))
                 |> ignore(string("'"))
                 |> reduce({List, :to_string, []})

  defcombinator :ignore_whitespace_and_comments,
                choice([
                  ascii_string(@whitespace_ascii, min: 1),
                  string("/*") |> eventually(string("*/")),
                  string("//") |> eventually(choice([ascii_char([?\n]), eos()]))
                ])
                |> times(min: 1)
                |> ignore()
end

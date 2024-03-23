defmodule ExDbml.Combinators.Common.Dynamic do
  @moduledoc false
  # NOTES:
  # - This module contains combinators that require parameters. If a combinator does not require
  #   parameters, it should be placed in `ExDbml.Combinators.Common.Static` to improve the
  #   compilation time of the modules.
  # - Tag the combinators from the caller to increase flexibility and reusability.
  # - Every combinator ignores whitespace and comments before the parsing starts to avoid spamming
  #   `ignore_whitespace_and_comments` in the caller.

  import NimbleParsec
  alias ExDbml.Combinators.Common.Static

  @downcase_ascii_offset 32

  @spec keyword(binary()) :: NimbleParsec.t()
  def keyword(key) when is_binary(key) do
    ignore(keyword_key(key))
    |> optional(parsec({Static, :ignore_whitespace_and_comments}))
    |> choice([
      integer(min: 1),
      ignorecase("true") |> replace(true),
      ignorecase("false") |> replace(false),
      ignorecase("null") |> replace(nil),
      parsec({Static, :dbml_string}),
      parsec({Static, :expression})
    ])
  end

  @spec string_keyword(binary()) :: NimbleParsec.t()
  def string_keyword(key) when is_binary(key) do
    ignore(keyword_key(key)) |> parsec({Static, :dbml_string})
  end

  @spec choice_keyword(binary(), list(binary())) :: NimbleParsec.t()
  def choice_keyword(key, values) when is_binary(key) and is_list(values) do
    ignore(keyword_key(key))
    |> optional(parsec({Static, :ignore_whitespace_and_comments}))
    |> choice(Enum.map(values, &string/1))
  end

  @spec hex_keyword(binary()) :: NimbleParsec.t()
  def hex_keyword(key) when is_binary(key) do
    ignore(keyword_key(key)) |> parsec({Static, :hex})
  end

  @spec keyword_key(binary()) :: NimbleParsec.t()
  def keyword_key(key) when is_binary(key) do
    ignorecase(key) |> ignore(word(":"))
  end

  def keyword_key do
    parsec({Static, :quoteless_name}) |> ignore(word(":"))
  end

  @spec ignorecase_words(list(binary())) :: NimbleParsec.t()
  def ignorecase_words(words) when is_list(words) do
    Enum.reduce(words, empty(), &ignorecase_word_reducer/2)
  end

  defp ignorecase_word_reducer(word, combinator) when is_binary(word) do
    combinator |> concat(ignorecase(word))
  end

  @spec ignorecase(binary()) :: NimbleParsec.t()
  def ignorecase(string) when is_binary(string) do
    optional(parsec({Static, :ignore_whitespace_and_comments}))
    |> reduce(ignorecase_string(string), {List, :to_string, []})
    |> label("case insensitive string `#{string}`")
  end

  defp ignorecase_string(string) when is_binary(string) do
    string
    |> String.upcase()
    |> String.to_charlist()
    |> Enum.reduce(empty(), &ignorecase_char/2)
  end

  defp ignorecase_char(char, acc_combinator) when char in ?A..?Z do
    ascii_char(acc_combinator, [char, char + @downcase_ascii_offset])
  end

  defp ignorecase_char(char, acc_combinator) do
    ascii_char(acc_combinator, [char])
  end

  @spec words(list(binary())) :: NimbleParsec.t()
  def words(words) when is_list(words) do
    Enum.reduce(words, empty(), &word_reducer/2)
  end

  defp word_reducer(word, combinator) when is_binary(word) do
    combinator |> concat(word(word))
  end

  # TODO: remove list parameter
  @spec curly_brackets_block(list(NimbleParsec.t())) :: NimbleParsec.t()
  def curly_brackets_block(combinators) when is_list(combinators) do
    ignore(word("{"))
    |> optional(parsec({Static, :ignore_whitespace_and_comments}))
    |> concat(merge_combinators(combinators))
    |> optional(parsec({Static, :ignore_whitespace_and_comments}))
    |> ignore(word("}"))
  end

  defp merge_combinators(combinators) when is_list(combinators) do
    Enum.reduce(Enum.reverse(combinators), empty(), &concat/2)
  end

  # TODO: fix spec hint
  @spec settings_block(choices: list(NimbleParsec.t())) :: NimbleParsec.t()
  def settings_block(choices: choices) when is_list(choices) do
    ignore(word("["))
    |> optional(parsec({Static, :ignore_whitespace_and_comments}))
    |> optional(times(choice(choices) |> optional(ignore(word(","))), min: 1))
    |> optional(parsec({Static, :ignore_whitespace_and_comments}))
    |> ignore(word("]"))
  end

  @spec settings_block(NimbleParsec.t()) :: NimbleParsec.t()
  def settings_block(combinator) do
    ignore(word("["))
    |> optional(parsec({Static, :ignore_whitespace_and_comments}))
    |> concat(combinator)
    |> optional(parsec({Static, :ignore_whitespace_and_comments}))
    |> ignore(word("]"))
  end

  @spec word(binary()) :: NimbleParsec.t()
  def word(word) when is_binary(word) do
    optional(parsec({Static, :ignore_whitespace_and_comments}))
    |> string(word)
  end

  @spec unordered_choice(list(NimbleParsec.t()), min: non_neg_integer()) :: NimbleParsec.t()
  def unordered_choice(choices, min: min) when is_list(choices) and is_integer(min) do
    optional(parsec({Static, :ignore_whitespace_and_comments}))
    |> times(choice(choices), min: min)
  end
end

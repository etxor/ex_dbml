defmodule ExDbml.Combinators.ProjectHelper do
  @moduledoc false
  import ExDbml.Combinators.Common.Dynamic
  import NimbleParsec
  alias ExDbml.Combinators.Common.Static

  @spec project() :: NimbleParsec.t()
  def project do
    type()
    |> optional(project_name())
    |> concat(project_definition())
  end

  defp type, do: ignorecase("project") |> replace(:project) |> unwrap_and_tag(:type)

  defp project_name, do: parsec({Static, :name}) |> unwrap_and_tag(:name)

  defp project_definition do
    curly_brackets_block([
      [
        parsec({Static, :note}) |> unwrap_and_tag(:note),
        custom_property(),
        parsec({Static, :ignore_whitespace_and_comments})
      ]
      |> unordered_choice(min: 0)
    ])
  end

  # NOTE: It always returns a single value list, this is done to make the project parsing simplier
  defp custom_property do
    unwrap_and_tag(keyword_key(), :key)
    |> unwrap_and_tag(parsec({Static, :dbml_string}), :value)
    |> wrap()
    |> tag(:custom_properties)
  end
end

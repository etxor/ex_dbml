defmodule ExDbml.Combinators.Relationship do
  @moduledoc false
  import ExDbml.Combinators.RelationshipHelper
  import NimbleParsec

  defcombinator :parse, relationship()
  defcombinator :parse_inline_relationship, inline_relationship()
end

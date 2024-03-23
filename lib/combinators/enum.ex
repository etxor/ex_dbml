defmodule ExDbml.Combinators.Enum do
  @moduledoc false
  import ExDbml.Combinators.EnumHelper
  import NimbleParsec

  defcombinator :parse, enum()
end

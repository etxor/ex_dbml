defmodule ExDbml.Combinators.Table do
  @moduledoc false
  import ExDbml.Combinators.TableHelper
  import NimbleParsec

  defcombinator :parse, table()
end

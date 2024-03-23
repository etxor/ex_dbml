defmodule ExDbml.Combinators.TableGroup do
  @moduledoc false
  import ExDbml.Combinators.TableGroupHelper
  import NimbleParsec

  defcombinator :parse, table_group()
end

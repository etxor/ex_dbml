defmodule ExDbml.Combinators.Project do
  @moduledoc false
  import ExDbml.Combinators.ProjectHelper
  import NimbleParsec

  defcombinator :parse, project()
end

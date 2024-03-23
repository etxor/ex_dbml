defmodule ExDbml.ExDbmlTest do
  @moduledoc false
  use ExUnit.Case, async: true
  doctest ExDbml

  # table that doesn't have an schema by default belongs to public
end

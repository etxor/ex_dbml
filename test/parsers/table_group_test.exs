defmodule ExDbml.ParsersTableGroupTest do
  @moduledoc false
  use ExUnit.Case, async: true
  alias ExDbml.Parser
  alias ExDbml.Structs.TableGroup
  alias ExDbml.Structs.TableGroupTable

  describe "Parse table group definitions" do
    test "Parse minimal definition" do
      dbml = "TableGroup e-commerce1 {
        merchants
        countries
      }"

      assert {:ok, [table_group]} = Parser.parse_table_groups(dbml)

      assert %TableGroup{
               name: "e-commerce1",
               tables: [%TableGroupTable{name: "merchants"}, %TableGroupTable{name: "countries"}]
             } == table_group
    end

    test "Parse schema" do
      dbml = "TableGroup e-commerce1 {
        ecommerce.merchants
      }"

      assert {:ok, [table_group]} = Parser.parse_table_groups(dbml)

      assert %TableGroup{
               name: "e-commerce1",
               tables: [%TableGroupTable{schema: "ecommerce", name: "merchants"}]
             } == table_group
    end

    test "Parse single line comments" do
      dbml = "// Start of table group
      TableGroup e-commerce1 { // a comment
          merchants // a comment
          countries // a comment
      } //
      // End of table group"

      assert {:ok, [table_group]} = Parser.parse_table_groups(dbml)

      assert %TableGroup{
               name: "e-commerce1",
               tables: [%TableGroupTable{name: "merchants"}, %TableGroupTable{name: "countries"}]
             } == table_group
    end

    test "Parse multi line comments" do
      dbml = "/**/ TableGroup /**/ e-commerce1 /**/ { /**/
        /* standalone comment */
        /**/ merchants /**/
        /**/ countries /**/
      } /**/"

      assert {:ok, [table_group]} = Parser.parse_table_groups(dbml)

      assert %TableGroup{
               name: "e-commerce1",
               tables: [%TableGroupTable{name: "merchants"}, %TableGroupTable{name: "countries"}]
             } == table_group
    end
  end
end

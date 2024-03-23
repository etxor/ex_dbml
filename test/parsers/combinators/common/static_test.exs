defmodule ExDbml.ParsersCombinatorsCommonStaticTest do
  @moduledoc false
  use ExUnit.Case, async: true
  alias ExDbml.Parser
  alias ExDbml.Structs.Project
  alias ExDbml.Structs.Table
  alias ExDbml.Structs.TableColumn
  alias ExDbml.Structs.TableColumnType

  describe "Parse name" do
    test "Parse downcase name" do
      name = "project_name"
      dbml = "Project #{name} {
      }"

      assert {:ok, [project]} = Parser.parse_projects(dbml)
      assert %Project{name: ^name} = project
    end

    test "Parse uppercase name" do
      name = "PROJECT_NAME"
      dbml = "Project #{name} {
      }"

      assert {:ok, [project]} = Parser.parse_projects(dbml)
      assert %Project{name: ^name} = project
    end

    test "Parse single character name" do
      name = "_"
      dbml = "Project #{name} {
      }"

      assert {:ok, [project]} = Parser.parse_projects(dbml)
      assert %Project{name: ^name} = project
    end

    test "Parse name that starts with number and length >= 2" do
      name = "8b"
      dbml = "Project #{name} {
      }"

      assert {:ok, [project]} = Parser.parse_projects(dbml)
      assert %Project{name: ^name} = project
    end

    test "Parse name with numbers" do
      name = "8b_7a"
      dbml = "Project #{name} {
      }"

      assert {:ok, [project]} = Parser.parse_projects(dbml)
      assert %Project{name: ^name} = project
    end

    test "Parse name in double quotes with spaces" do
      name = "  project   name  "
      dbml = "Project \"#{name}\" {
      }"

      assert {:ok, [project]} = Parser.parse_projects(dbml)
      assert %Project{name: ^name} = project
    end

    test "Support UTF-8 characters in double quoted name" do
      name = "🚀"
      dbml = "Project \"#{name}\" {
      }"

      assert {:ok, [project]} = Parser.parse_projects(dbml)
      assert %Project{name: ^name} = project
    end
  end

  describe "Parse dbml string" do
    test "Parse multi line dbml string" do
      note = ~S(
        Description of the project
        Second line
      )
      dbml = "Project project_name {
        Note: '''#{note}'''
      }"

      assert {:ok, [project]} = Parser.parse_projects(dbml)
      assert %Project{note: ^note} = project
    end

    # TODO: implement these tests
    #   test "Parse line continuation in multi line dbml string" do
    #     dbml = "Project project_name {
    #       Note: '''First line\\
    #       Second line\\
    #       '''
    #     }"

    #     assert %{note: "First line        Second line        "} = to_map(Parser.parse_projects(dbml))
    #   end

    #   test "Parse backslash escape in multi line dbml string" do
    #     dbml = "Project project_name {
    #       Note: '''A backslash: \\\\'''
    #     }"

    #     assert %{note: "A backslash: \\"} = to_map(Parser.parse_projects(dbml))
    #   end
    # TODO: test single quote escape in multi line dbml string
    test "Support UTF-8 characters in multi line dbml string" do
      dbml = "Project project_name {
        Note: '''🚀 A rocket'''
      }"
      assert {:ok, [project]} = Parser.parse_projects(dbml)
      assert %Project{note: "🚀 A rocket"} = project
    end

    # TODO: test single quote escape in inline dbml string
    test "Support UTF-8 characters in inline dbml string" do
      dbml = "Project project_name {
        Note: '🚀 A rocket'
      }"
      assert {:ok, [project]} = Parser.parse_projects(dbml)
      assert %Project{note: "🚀 A rocket"} = project
    end
  end

  describe "Parse notes" do
    test "Parse multi line note" do
      dbml = "Project project_name {
        Note {
          'Description of the project'
        }
      }"
      assert {:ok, [project]} = Parser.parse_projects(dbml)
      assert %Project{note: "Description of the project"} = project
    end
  end

  describe "Parse functions" do
    test "Parse function without parameters" do
      dbml = "Table table_name {
        no_parens_column column_type
        parens_column column_type()
      }"

      assert {:ok, [table]} = Parser.parse_tables(dbml)

      assert %Table{
               columns: [
                 %TableColumn{
                   name: "no_parens_column",
                   type: %TableColumnType{name: "column_type", params: []}
                 },
                 %TableColumn{
                   name: "parens_column",
                   type: %TableColumnType{name: "column_type", params: []}
                 }
               ]
             } = table
    end

    test "Parse dbml string, name and integer as single parameters" do
      dbml = "Table table_name {
        integer_column integer_type(10)
        name_column name_type(name)
        string_column dbml_string('🚀')
      }"

      assert {:ok, [table]} = Parser.parse_tables(dbml)

      assert %Table{
               columns: [
                 %TableColumn{
                   name: "integer_column",
                   type: %TableColumnType{name: "integer_type", params: [10]}
                 },
                 %TableColumn{
                   name: "name_column",
                   type: %TableColumnType{name: "name_type", params: ["name"]}
                 },
                 %TableColumn{
                   name: "string_column",
                   type: %TableColumnType{name: "dbml_string", params: ["🚀"]}
                 }
               ]
             } = table
    end

    test "Parse dbml string, name and integer as multiple parameters" do
      dbml = "Table table_name {
        integer_column integer_type(10, 2)
        name_column name_type(name, \"double quoted name\")
        string_column dbml_string('🚀', '🚀🚀')
      }"

      assert {:ok, [table]} = Parser.parse_tables(dbml)

      assert %Table{
               columns: [
                 %TableColumn{
                   name: "integer_column",
                   type: %TableColumnType{name: "integer_type", params: [10, 2]}
                 },
                 %TableColumn{
                   name: "name_column",
                   type: %TableColumnType{
                     name: "name_type",
                     params: ["name", "double quoted name"]
                   }
                 },
                 %TableColumn{
                   name: "string_column",
                   type: %TableColumnType{name: "dbml_string", params: ["🚀", "🚀🚀"]}
                 }
               ]
             } = table
    end

    # TODO: parse_projects invalid function column_name column_type(
  end
end

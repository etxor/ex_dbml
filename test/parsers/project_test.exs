defmodule ExDbml.ParsersProjectTest do
  @moduledoc false
  use ExUnit.Case, async: true
  alias ExDbml.Parser
  alias ExDbml.Structs.CustomProperty
  alias ExDbml.Structs.Project

  describe "Parse project definitions" do
    test "Parse minimal definition" do
      project_dbml = "Project {
      }"

      assert {:ok, [%Project{}]} == Parser.parse_projects(project_dbml)
    end

    test "Parse inline note" do
      project_dbml = "Project project_name {
        Note: 'Description of the project'
      }"

      assert {:ok, [project]} = Parser.parse_projects(project_dbml)
      assert %Project{name: "project_name", note: "Description of the project"} == project
    end

    test "Parse custom properties" do
      project_dbml = "Project project_name {
        database_type: 'PostgreSQL'
      }"

      assert {:ok, [project]} = Parser.parse_projects(project_dbml)

      assert %Project{
               name: "project_name",
               custom_properties: [%CustomProperty{key: "database_type", value: "PostgreSQL"}]
             } == project
    end

    test "Parse custom properties splitted by note" do
      project_dbml = "Project project_name {
        database_type: 'PostgreSQL'
        Note: 'Description of the project'
        database_name: 'database_name'
      }"

      assert {:ok, [project]} = Parser.parse_projects(project_dbml)

      assert %Project{
               name: "project_name",
               custom_properties: [
                 %CustomProperty{key: "database_type", value: "PostgreSQL"},
                 %CustomProperty{key: "database_name", value: "database_name"}
               ],
               note: "Description of the project"
             } == project
    end

    test "Parse single line comments" do
      project_dbml = "// start of project
      Project project_name { // comment
        // standalone comment
        database_type: 'PostgreSQL' // comment
        Note: 'Description of the project' // comment
      } //
      // end of project"

      assert {:ok, [project]} = Parser.parse_projects(project_dbml)

      assert %Project{
               name: "project_name",
               custom_properties: [%CustomProperty{key: "database_type", value: "PostgreSQL"}],
               note: "Description of the project"
             } == project
    end

    test "Parse multi line comments" do
      project_dbml = "/**/ Project /**/ project_name /**/ { /**/
            /* standalone comment */
            /**/ database_type /**/ : /**/ 'PostgreSQL' /**/
            /**/ Note /**/ : /**/ 'Description of the project' /**/
          /**/ } /**/"

      assert {:ok, [project]} = Parser.parse_projects(project_dbml)

      assert %Project{
               name: "project_name",
               custom_properties: [%CustomProperty{key: "database_type", value: "PostgreSQL"}],
               note: "Description of the project"
             } == project
    end
  end
end

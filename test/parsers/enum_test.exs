defmodule ExDbml.ParsersEnumTest do
  @moduledoc false
  use ExUnit.Case, async: true
  alias ExDbml.Parser
  alias ExDbml.Structs.Enum
  alias ExDbml.Structs.EnumValue

  describe "Parse enum definitions" do
    test "Parse minimal definition" do
      dbml = "Enum job_status {
        choice
      }"

      assert {:ok, [enum]} = Parser.parse_enums(dbml)
      assert %Enum{name: "job_status", values: [%EnumValue{name: "choice"}]} == enum
    end

    test "Parse values in double quotes" do
      dbml = ~S(enum statuses {
        "💸 1 = processing"
        "✔️ 2 = shipped"
        "❌ 3 = cancelled"
        "😔 4 = refunded"
      })

      assert {:ok, [enum]} = Parser.parse_enums(dbml)

      assert %Enum{
               values: [
                 %EnumValue{name: "💸 1 = processing"},
                 %EnumValue{name: "✔️ 2 = shipped"},
                 %EnumValue{name: "❌ 3 = cancelled"},
                 %EnumValue{name: "😔 4 = refunded"}
               ]
             } = enum
    end

    test "Parse schema name" do
      dbml = "Enum v2.job_status {
        choice
      }"

      assert {:ok, [%Enum{schema: "v2"}]} = Parser.parse_enums(dbml)
    end

    test "Parse values' inline note" do
      dbml = "Enum job_status {
        choice [note: 'This is a note']
        second_choice [note: 'This is another note']
      }"

      assert {:ok, [enum]} = Parser.parse_enums(dbml)

      assert %Enum{
               values: [
                 %EnumValue{name: "choice", note: "This is a note"},
                 %EnumValue{name: "second_choice", note: "This is another note"}
               ]
             } = enum
    end

    test "Parse single line comments" do
      dbml = "// Start of enum
        Enum job_status { // a comment
        choice [note: 'This is a note'] // a comment
        second_choice [note: 'This is another note'] // a comment
      } //
      // End of enum"

      assert {:ok, [enum]} = Parser.parse_enums(dbml)

      assert %Enum{
               name: "job_status",
               values: [
                 %EnumValue{name: "choice", note: "This is a note"},
                 %EnumValue{name: "second_choice", note: "This is another note"}
               ]
             } == enum
    end

    test "Parse multi line comments" do
      dbml = "/**/ Enum /**/ job_status /**/ { /**/
        /* standalone comment */
        /**/ choice /**/ [ /**/ note: /**/ 'This is a note' /**/ ] /**/
        /**/ second_choice /**/ [ /**/ note: /**/ 'This is another note' /**/ ] /**/
      } /**/"

      assert {:ok, [enum]} = Parser.parse_enums(dbml)

      assert %Enum{
               name: "job_status",
               values: [
                 %EnumValue{name: "choice", note: "This is a note"},
                 %EnumValue{name: "second_choice", note: "This is another note"}
               ]
             } == enum
    end
  end
end

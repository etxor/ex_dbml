defmodule ExDbml.ParsersTableColumnTest do
  @moduledoc false
  use ExUnit.Case, async: true
  alias ExDbml.Structs.TableColumnSettings
  alias ExDbml.Parser
  alias ExDbml.Structs.Table
  alias ExDbml.Structs.TableColumn
  alias ExDbml.Structs.TableColumnType

  describe "Parse column definition" do
    test "Parse column types" do
      table_dbml = ~S(Table table_name {
        column_name column_type
        paramless_column paramless(\)
        spaced_paramless_column paramless  (  \)
        varchar_column varchar(255\)
        decimal_column decimal(10, 2\)
        upcase_decimal_column DECIMAL(10, 2\)
        spaced_decimal_column decimal  (  10  , 2  \)
        JSONB_column JSONB
        "  column name  " "  column type  "
      })

      assert {:ok, [table]} = Parser.parse_tables(table_dbml)

      assert %Table{
               name: "table_name",
               columns: [
                 %TableColumn{name: "column_name", type: %TableColumnType{name: "column_type"}},
                 %TableColumn{
                   name: "paramless_column",
                   type: %TableColumnType{name: "paramless"}
                 },
                 %TableColumn{
                   name: "spaced_paramless_column",
                   type: %TableColumnType{name: "paramless"}
                 },
                 %TableColumn{
                   name: "varchar_column",
                   type: %TableColumnType{name: "varchar", params: [255]}
                 },
                 %TableColumn{
                   name: "decimal_column",
                   type: %TableColumnType{name: "decimal", params: [10, 2]}
                 },
                 %TableColumn{
                   name: "upcase_decimal_column",
                   type: %TableColumnType{name: "DECIMAL", params: [10, 2]}
                 },
                 %TableColumn{
                   name: "spaced_decimal_column",
                   type: %TableColumnType{name: "decimal", params: [10, 2]}
                 },
                 %TableColumn{name: "JSONB_column", type: %TableColumnType{name: "JSONB"}},
                 %TableColumn{
                   name: "  column name  ",
                   type: %TableColumnType{name: "  column type  "}
                 }
               ]
             } == table
    end

    test "Parse column with enum type" do
      table_dbml = "Table inventory.orders {
        status inventory.order_status
      }"

      assert {:ok, [table]} = Parser.parse_tables(table_dbml)

      assert %Table{
               schema: "inventory",
               name: "orders",
               columns: [
                 %TableColumn{
                   name: "status",
                   # TODO: Support enum type, instead of only concatenating the schema and type
                   type: %TableColumnType{name: "inventoryorder_status"}
                 }
               ]
             } == table
    end

    test "Parse column settings" do
      table_dbml = "Table table_name {
        column column_type []

        note_column downcase_type [note: 'Description of column']
        pk_column downcase_type [pk]
        primary_key_column downcase_type [primary   key]
        null_column downcase_type [null]
        not_null_column downcase_type [not    null]
        unique_column downcase_type [unique]
        default_column downcase_type [default: 'default']
        increment_column downcase_type [increment]

        note_column upcase_type [NOTE: 'Description of column']
        pk_column upcase_type [PK]
        primary_key_column upcase_type [PRIMARY   KEY]
        null_column upcase_type [NULL]
        not_null_column upcase_type [NOT    NULL]
        unique_column upcase_type [UNIQUE]
        default_column upcase_type [DEFAULT: 'default']
        increment_column upcase_type [INCREMENT]
      }"

      assert {:ok, [table]} = Parser.parse_tables(table_dbml)

      assert %Table{
               name: "table_name",
               columns: [
                 %TableColumn{
                   name: "column",
                   type: %TableColumnType{name: "column_type"},
                   settings: %TableColumnSettings{}
                 },
                 %TableColumn{
                   name: "note_column",
                   type: %TableColumnType{name: "downcase_type"},
                   settings: %TableColumnSettings{note: "Description of column"}
                 },
                 %TableColumn{
                   name: "pk_column",
                   type: %TableColumnType{name: "downcase_type"},
                   settings: %TableColumnSettings{pk: true}
                 },
                 %TableColumn{
                   name: "primary_key_column",
                   type: %TableColumnType{name: "downcase_type"},
                   settings: %TableColumnSettings{primary_key: true}
                 },
                 %TableColumn{
                   name: "null_column",
                   type: %TableColumnType{name: "downcase_type"},
                   settings: %TableColumnSettings{null: true}
                 },
                 %TableColumn{
                   name: "not_null_column",
                   type: %TableColumnType{name: "downcase_type"},
                   settings: %TableColumnSettings{not_null: true}
                 },
                 %TableColumn{
                   name: "unique_column",
                   type: %TableColumnType{name: "downcase_type"},
                   settings: %TableColumnSettings{unique: true}
                 },
                 %TableColumn{
                   name: "default_column",
                   type: %TableColumnType{name: "downcase_type"},
                   settings: %TableColumnSettings{default: "default"}
                 },
                 %TableColumn{
                   name: "increment_column",
                   type: %TableColumnType{name: "downcase_type"},
                   settings: %TableColumnSettings{increment: true}
                 },
                 %TableColumn{
                   name: "note_column",
                   type: %TableColumnType{name: "upcase_type"},
                   settings: %TableColumnSettings{note: "Description of column"}
                 },
                 %TableColumn{
                   name: "pk_column",
                   type: %TableColumnType{name: "upcase_type"},
                   settings: %TableColumnSettings{pk: true}
                 },
                 %TableColumn{
                   name: "primary_key_column",
                   type: %TableColumnType{name: "upcase_type"},
                   settings: %TableColumnSettings{primary_key: true}
                 },
                 %TableColumn{
                   name: "null_column",
                   type: %TableColumnType{name: "upcase_type"},
                   settings: %TableColumnSettings{null: true}
                 },
                 %TableColumn{
                   name: "not_null_column",
                   type: %TableColumnType{name: "upcase_type"},
                   settings: %TableColumnSettings{not_null: true}
                 },
                 %TableColumn{
                   name: "unique_column",
                   type: %TableColumnType{name: "upcase_type"},
                   settings: %TableColumnSettings{unique: true}
                 },
                 %TableColumn{
                   name: "default_column",
                   type: %TableColumnType{name: "upcase_type"},
                   settings: %TableColumnSettings{default: "default"}
                 },
                 %TableColumn{
                   name: "increment_column",
                   type: %TableColumnType{name: "upcase_type"},
                   settings: %TableColumnSettings{increment: true}
                 }
               ]
             } == table
    end

    test "Parse multiple column settings separated by , " do
      table_dbml = "Table table_name {
        column_name column_type [increment, not null  , default: 1]
      }"

      assert {:ok, [table]} = Parser.parse_tables(table_dbml)

      assert %Table{
               name: "table_name",
               columns: [
                 %TableColumn{
                   name: "column_name",
                   type: %TableColumnType{name: "column_type"},
                   settings: %TableColumnSettings{increment: true, not_null: true, default: 1}
                 }
               ]
             } == table
    end

    test "Parse column default setting's values" do
      table_dbml = "Table table_name {
        number_column integer [default: 123]
        string_column varchar(255) [default: 'some string']
        true_boolean_column boolean [default: true]
        false_boolean_column boolean [default: false]
        null_column varchar(255) [default: null]
        expression_column datetime [default: `now() - interval '5 days'`]
      }"

      assert {:ok, [table]} = Parser.parse_tables(table_dbml)

      assert %Table{
               name: "table_name",
               columns: [
                 %TableColumn{
                   name: "number_column",
                   type: %TableColumnType{name: "integer"},
                   settings: %TableColumnSettings{default: 123}
                 },
                 %TableColumn{
                   name: "string_column",
                   type: %TableColumnType{name: "varchar", params: [255]},
                   settings: %TableColumnSettings{default: "some string"}
                 },
                 %TableColumn{
                   name: "true_boolean_column",
                   type: %TableColumnType{name: "boolean"},
                   settings: %TableColumnSettings{default: true}
                 },
                 %TableColumn{
                   name: "false_boolean_column",
                   type: %TableColumnType{name: "boolean"},
                   settings: %TableColumnSettings{default: false}
                 },
                 %TableColumn{
                   name: "null_column",
                   type: %TableColumnType{name: "varchar", params: [255]},
                   settings: %TableColumnSettings{default: nil}
                 },
                 %TableColumn{
                   name: "expression_column",
                   type: %TableColumnType{name: "datetime"},
                   settings: %TableColumnSettings{default: "now() - interval '5 days'"}
                 }
               ]
             } == table
    end

    test "Parse single line comments in column definition" do
      table_dbml = "Table table_name {
        column_name column_type // comment
      }"

      assert {:ok, [table]} = Parser.parse_tables(table_dbml)

      assert %Table{
               name: "table_name",
               columns: [
                 %TableColumn{
                   name: "column_name",
                   type: %TableColumnType{name: "column_type"}
                 }
               ]
             } == table
    end

    test "Parse multi line comments in column definition" do
      table_dbml = ~S(Table table_name {
        /**/ column_name /**/ column_type /**/
        /**/ decimal_column /**/ decimal  /**/ ( /**/ 10 /**/ , /**/ 2 /**/\) /**/
        /**/ " double quote name  " /**/ "  column type  " /**/
        /**/ settings_column /**/ column_type /**/ [ /**/ pk /**/ , /**/ not /**/ null /**/ ,  /**/ note /**/ : /**/ 'Description of column' /**/ ] /**/
        /**/ default_expression_column /**/ datetime /**/ [ /**/ default /**/ : /**/ `now(\) - interval '5 days'` /**/ ] /**/
      })

      assert {:ok, [table]} = Parser.parse_tables(table_dbml)

      assert %Table{
               name: "table_name",
               columns: [
                 %TableColumn{
                   name: "column_name",
                   type: %TableColumnType{name: "column_type"}
                 },
                 %TableColumn{
                   name: "decimal_column",
                   type: %TableColumnType{name: "decimal", params: [10, 2]}
                 },
                 %TableColumn{
                   name: " double quote name  ",
                   type: %TableColumnType{name: "  column type  "}
                 },
                 %TableColumn{
                   name: "settings_column",
                   type: %TableColumnType{name: "column_type"},
                   settings: %TableColumnSettings{
                     pk: true,
                     not_null: true,
                     note: "Description of column"
                   }
                 },
                 %TableColumn{
                   name: "default_expression_column",
                   type: %TableColumnType{name: "datetime"},
                   settings: %TableColumnSettings{default: "now() - interval '5 days'"}
                 }
               ]
             } == table
    end
  end

  # TODO: error when pk and primary key are present (DBML Level)
  # TODO: error when null and not null are present (DBML Level)
end

defmodule ExDbml.ParsersTableTest do
  @moduledoc false
  use ExUnit.Case, async: true
  alias ExDbml.Structs.TableColumnSettings
  alias ExDbml.Structs.InlineRelationship
  alias ExDbml.Structs.TableSettings
  alias ExDbml.Parser
  alias ExDbml.Structs.RelationshipTable
  alias ExDbml.Structs.Table
  alias ExDbml.Structs.TableColumn
  alias ExDbml.Structs.TableColumnType
  alias ExDbml.Structs.TableIndex
  alias ExDbml.Structs.TableIndexSettings

  describe "Parse table definition" do
    test "Parse minimal table definition" do
      table_dbml = "Table table_name {
        column_name column_type
      }"

      assert {:ok, [table]} = Parser.parse_tables(table_dbml)

      assert %Table{
               name: "table_name",
               columns: [
                 %TableColumn{name: "column_name", type: %TableColumnType{name: "column_type"}}
               ]
             } == table
    end

    test "Parse schema" do
      table_dbml = "Table v2.table_name {
        column_name column_type
      }"
      assert {:ok, [%Table{schema: "v2"}]} = Parser.parse_tables(table_dbml)
    end

    test "Parse table alias" do
      table_dbml = "Table table_name AS TN {
        column_name column_type
      }"
      assert {:ok, [%Table{alias: "TN"}]} = Parser.parse_tables(table_dbml)
    end

    test "Parse table settings" do
      table_dbml = "Table users [headercolor: #3498DB, note: 'Table description'] {
        column_name column_type
      }"

      assert {:ok, [table]} = Parser.parse_tables(table_dbml)

      assert %Table{
               name: "users",
               settings: %TableSettings{headercolor: "#3498DB", note: "Table description"},
               columns: [
                 %TableColumn{name: "column_name", type: %TableColumnType{name: "column_type"}}
               ]
             } == table
    end

    # TODO: it should return an error instead of parsing as a valid value
    # test "Parse multiple table notes with separated column definitions" do
    #   table_dbml = "Table table_name {
    #     NOTE: 'Description of the table I'
    #     column_name column_type
    #     NOTE: 'Description of the table II'
    #     column_name column_type
    #     NOTE: 'Description of the table III'
    #   }"

    #   assert {:ok,
    #           [
    #             type: :table,
    #             name: "table_name",
    #             note: "Description of the table I",
    #             columns: [[name: "column_name", type: [name: "column_type"]]],
    #             note: "Description of the table II",
    #             columns: [[name: "column_name", type: [name: "column_type"]]],
    #             note: "Description of the table III"
    #           ]} == Parser.parse_tables(table_dbml)
    # end

    test "Parse single line comments in table definition" do
      table_dbml = "// start of table
      Table table_name { // comment
        // standalone comment
        column_name column_type // comment
      } // comment
      // end of table"

      assert {:ok, [table]} = Parser.parse_tables(table_dbml)

      assert %Table{
               name: "table_name",
               columns: [
                 %TableColumn{name: "column_name", type: %TableColumnType{name: "column_type"}}
               ]
             } == table
    end

    test "Parse multi line comments in table definition" do
      table_dbml =
        "/**/ Table /**/ table_name /**/ as /**/ T /**/ [ /**/ note /**/ : /**/ 'Description of the table' /**/ , /**/ headercolor /**/ : /**/ #3498DB /**/ ] /**/ { /**/
            /* standalone comment */
            /**/ column_name /**/ column_type /*
                splitted comment  */
          /**/ } /**/"

      assert {:ok, [table]} = Parser.parse_tables(table_dbml)

      assert %Table{
               name: "table_name",
               alias: "T",
               settings: %TableSettings{note: "Description of the table", headercolor: "#3498DB"},
               columns: [
                 %TableColumn{name: "column_name", type: %TableColumnType{name: "column_type"}}
               ]
             } == table
    end
  end

  describe "Parse table's indexes" do
    test "Parse all index variations" do
      table_dbml = "Table bookings {
        id integer
        country varchar
        booking_date date
        created_at timestamp

        Indexes {
          (  id , country  ) [pk]
          created_at [name: 'created_at_index', note: 'Date']
          \"booking_date\"
          (country, booking_date) [unique]
          booking_date [type: hash]
          booking_date [type: btree]
          `id*4`
          (`id*2`)
          (`id*3`,`getdate()`)
          (`id*3`,id)
        }
      }"

      assert {:ok, [table]} = Parser.parse_tables(table_dbml)

      assert %Table{
               name: "bookings",
               columns: [
                 %TableColumn{name: "id", type: %TableColumnType{name: "integer"}},
                 %TableColumn{name: "country", type: %TableColumnType{name: "varchar"}},
                 %TableColumn{name: "booking_date", type: %TableColumnType{name: "date"}},
                 %TableColumn{name: "created_at", type: %TableColumnType{name: "timestamp"}}
               ],
               indexes: [
                 %TableIndex{fields: ["id", "country"], settings: %TableIndexSettings{pk: true}},
                 %TableIndex{
                   fields: ["created_at"],
                   settings: %TableIndexSettings{name: "created_at_index", note: "Date"}
                 },
                 %TableIndex{fields: ["booking_date"]},
                 %TableIndex{
                   fields: ["country", "booking_date"],
                   settings: %TableIndexSettings{unique: true}
                 },
                 %TableIndex{
                   fields: ["booking_date"],
                   settings: %TableIndexSettings{type: "hash"}
                 },
                 %TableIndex{
                   fields: ["booking_date"],
                   settings: %TableIndexSettings{type: "btree"}
                 },
                 %TableIndex{fields: ["id*4"]},
                 %TableIndex{fields: ["id*2"]},
                 %TableIndex{fields: ["id*3", "getdate()"]},
                 %TableIndex{fields: ["id*3", "id"]}
               ]
             } == table
    end

    test "Parse multiple index sections in table definition" do
      table_dbml = "Table users {
        id integer
        Indexes {
          id
        }
        account_id integer
        Indexes {
          account_id
        }
      }"

      assert {:ok, [table]} = Parser.parse_tables(table_dbml)

      assert %Table{
               name: "users",
               columns: [
                 %TableColumn{name: "id", type: %TableColumnType{name: "integer"}},
                 %TableColumn{name: "account_id", type: %TableColumnType{name: "integer"}}
               ],
               indexes: [
                 %TableIndex{fields: ["id"]},
                 %TableIndex{fields: ["account_id"]}
               ]
             } == table
    end

    test "Parse single line comments in index definition" do
      table_dbml = "Table users {
        id integer
        // standalone comment
        Indexes { // comment
          id // comment
        } // comment
      }"

      assert {:ok, [table]} = Parser.parse_tables(table_dbml)

      assert %Table{
               name: "users",
               columns: [%TableColumn{name: "id", type: %TableColumnType{name: "integer"}}],
               indexes: [%TableIndex{fields: ["id"]}]
             } == table
    end

    test "Parse multi line comments in index definition" do
      table_dbml = "Table users {
        id integer
        /* standalone comment */
        /**/ Indexes /**/ { /**/
          /**/ id /**/
        /**/ } /**/
      }"

      assert {:ok, [table]} = Parser.parse_tables(table_dbml)

      assert %Table{
               name: "users",
               columns: [%TableColumn{name: "id", type: %TableColumnType{name: "integer"}}],
               indexes: [%TableIndex{fields: ["id"]}]
             } == table
    end
  end

  describe "Parse column's inline form relationship" do
    # TODO: random setting between two relationships for a column
    test "Parse all inline relationship types" do
      table_dbml = "Table users {
        id integer [ref: < posts.user_id  , ref: < reviews.user_id]
        post_id integer [ref: <> posts.id]
        group_id integer [ref: > groups.id]
        contact_id integer [ref: - marketing.contacts.id]
      }"

      assert {:ok, [table]} = Parser.parse_tables(table_dbml)

      assert %Table{
               name: "users",
               columns: [
                 %TableColumn{
                   name: "id",
                   type: %TableColumnType{name: "integer"},
                   settings: %TableColumnSettings{
                     relationships: [
                       %InlineRelationship{
                         relationship_type: :one_to_many,
                         target: %RelationshipTable{
                           name: "posts",
                           columns: ["user_id"]
                         }
                       },
                       %InlineRelationship{
                         relationship_type: :one_to_many,
                         target: %RelationshipTable{
                           name: "reviews",
                           columns: ["user_id"]
                         }
                       }
                     ]
                   }
                 },
                 %TableColumn{
                   name: "post_id",
                   type: %TableColumnType{name: "integer"},
                   settings: %TableColumnSettings{
                     relationships: [
                       %InlineRelationship{
                         relationship_type: :many_to_many,
                         target: %RelationshipTable{
                           name: "posts",
                           columns: ["id"]
                         }
                       }
                     ]
                   }
                 },
                 %TableColumn{
                   name: "group_id",
                   type: %TableColumnType{name: "integer"},
                   settings: %TableColumnSettings{
                     relationships: [
                       %InlineRelationship{
                         relationship_type: :many_to_one,
                         target: %RelationshipTable{
                           name: "groups",
                           columns: ["id"]
                         }
                       }
                     ]
                   }
                 },
                 %TableColumn{
                   name: "contact_id",
                   type: %TableColumnType{name: "integer"},
                   settings: %TableColumnSettings{
                     relationships: [
                       %InlineRelationship{
                         relationship_type: :one_to_one,
                         target: %RelationshipTable{
                           schema: "marketing",
                           name: "contacts",
                           columns: ["id"]
                         }
                       }
                     ]
                   }
                 }
               ]
             } == table
    end

    test "Parse single line comments in inline form relationships" do
      table_dbml = "Table users {
        id integer [ref: < posts.user_id  , ref: < reviews.user_id] // comment
      }"

      assert {:ok, [table]} = Parser.parse_tables(table_dbml)

      assert %Table{
               name: "users",
               columns: [
                 %TableColumn{
                   name: "id",
                   type: %TableColumnType{name: "integer"},
                   settings: %TableColumnSettings{
                     relationships: [
                       %InlineRelationship{
                         relationship_type: :one_to_many,
                         target: %RelationshipTable{
                           name: "posts",
                           columns: ["user_id"]
                         }
                       },
                       %InlineRelationship{
                         relationship_type: :one_to_many,
                         target: %RelationshipTable{
                           name: "reviews",
                           columns: ["user_id"]
                         }
                       }
                     ]
                   }
                 }
               ]
             } == table
    end

    test "Parse multi line comments in inline form relationships" do
      table_dbml = ~S(Table users {
        /**/ id /**/ integer /**/ [ /**/ ref /**/ : /**/ < /**/ posts.user_id /**/ , /**/ ref /**/ : /**/ < /**/ reviews.user_id /**/ ] /**/
      })

      assert {:ok, [table]} = Parser.parse_tables(table_dbml)

      assert %Table{
               name: "users",
               columns: [
                 %TableColumn{
                   name: "id",
                   type: %TableColumnType{name: "integer"},
                   settings: %TableColumnSettings{
                     relationships: [
                       %InlineRelationship{
                         relationship_type: :one_to_many,
                         target: %RelationshipTable{
                           name: "posts",
                           columns: ["user_id"]
                         }
                       },
                       %InlineRelationship{
                         relationship_type: :one_to_many,
                         target: %RelationshipTable{
                           name: "reviews",
                           columns: ["user_id"]
                         }
                       }
                     ]
                   }
                 }
               ]
             } == table
    end
  end

  describe "Random tests" do
  end

  # TODO: error when table columns are not present
  # TODO: error when table notes as column defintions are present more than once (DBML Level)
end

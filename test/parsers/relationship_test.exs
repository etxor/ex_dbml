defmodule ExDbml.ParsersRelationshipTest do
  @moduledoc false
  use ExUnit.Case, async: true
  alias ExDbml.Parser
  alias ExDbml.Structs.Relationship
  alias ExDbml.Structs.RelationshipSettings
  alias ExDbml.Structs.RelationshipTable

  describe "Parse relationships and foreign key definitions" do
    test "Parse short form relationships" do
      dbml = ~S(
        Ref spaced_rel_name : users.id < reviews.user_id
        Ref rel_name: users.post_id <> posts.id
        Ref "quoted rel name": users.group_id > groups.id
        Ref: marketing.contacts.id - accounts.users.contact_id
      )

      assert {:ok, relationships} = Parser.parse_relationships(dbml)

      assert [
               %Relationship{
                 name: "spaced_rel_name",
                 source: %RelationshipTable{name: "users", columns: ["id"]},
                 relationship_type: :one_to_many,
                 target: %RelationshipTable{name: "reviews", columns: ["user_id"]}
               },
               %Relationship{
                 name: "rel_name",
                 source: %RelationshipTable{name: "users", columns: ["post_id"]},
                 relationship_type: :many_to_many,
                 target: %RelationshipTable{name: "posts", columns: ["id"]}
               },
               %Relationship{
                 name: "quoted rel name",
                 source: %RelationshipTable{name: "users", columns: ["group_id"]},
                 relationship_type: :many_to_one,
                 target: %RelationshipTable{name: "groups", columns: ["id"]}
               },
               %Relationship{
                 source: %RelationshipTable{
                   schema: "marketing",
                   name: "contacts",
                   columns: ["id"]
                 },
                 relationship_type: :one_to_one,
                 target: %RelationshipTable{
                   schema: "accounts",
                   name: "users",
                   columns: ["contact_id"]
                 }
               }
             ] == relationships
    end

    test "Parse composite foreign key in short form relationship" do
      dbml =
        "Ref: ecommerce.merchant_periods.(merchant_id, country_code) > merchants.(id, country_code)"

      assert {:ok, [relationship]} = Parser.parse_relationships(dbml)

      assert %Relationship{
               source: %RelationshipTable{
                 schema: "ecommerce",
                 name: "merchant_periods",
                 columns: ["merchant_id", "country_code"]
               },
               relationship_type: :many_to_one,
               target: %RelationshipTable{name: "merchants", columns: ["id", "country_code"]}
             } == relationship
    end

    test "Parse settings in short form relationship" do
      dbml = "Ref: users.id < reviews.user_id [on_delete: set null , on_update: cascade]"

      assert {:ok, [relationship]} = Parser.parse_relationships(dbml)

      assert %Relationship{
               source: %RelationshipTable{name: "users", columns: ["id"]},
               relationship_type: :one_to_many,
               target: %RelationshipTable{name: "reviews", columns: ["user_id"]},
               settings: %RelationshipSettings{on_delete: :set_null, on_update: :cascade}
             } == relationship
    end

    test "Parse long form relationships" do
      dbml = ~S(
        Ref spaced_rel_name {
          users.id < reviews.user_id
        }
        Ref rel_name {
          users.post_id <> posts.id
        }
        Ref "quoted rel name" {
          users.group_id > groups.id
        }
        Ref {
          marketing.contacts.id - users.contact_id
        }
      )

      assert {:ok, relationships} = Parser.parse_relationships(dbml)

      assert [
               %Relationship{
                 name: "spaced_rel_name",
                 source: %RelationshipTable{name: "users", columns: ["id"]},
                 relationship_type: :one_to_many,
                 target: %RelationshipTable{name: "reviews", columns: ["user_id"]}
               },
               %Relationship{
                 name: "rel_name",
                 source: %RelationshipTable{name: "users", columns: ["post_id"]},
                 relationship_type: :many_to_many,
                 target: %RelationshipTable{name: "posts", columns: ["id"]}
               },
               %Relationship{
                 name: "quoted rel name",
                 source: %RelationshipTable{name: "users", columns: ["group_id"]},
                 relationship_type: :many_to_one,
                 target: %RelationshipTable{name: "groups", columns: ["id"]}
               },
               %Relationship{
                 source: %RelationshipTable{
                   schema: "marketing",
                   name: "contacts",
                   columns: ["id"]
                 },
                 relationship_type: :one_to_one,
                 target: %RelationshipTable{name: "users", columns: ["contact_id"]}
               }
             ] == relationships
    end

    test "Parse composite foreign key in long form relationship" do
      dbml =
        "Ref {
          ecommerce.merchant_periods.(merchant_id, country_code) > merchants.(id, country_code)
        }"

      assert {:ok, [relationship]} = Parser.parse_relationships(dbml)

      assert %Relationship{
               source: %RelationshipTable{
                 schema: "ecommerce",
                 name: "merchant_periods",
                 columns: ["merchant_id", "country_code"]
               },
               relationship_type: :many_to_one,
               target: %RelationshipTable{name: "merchants", columns: ["id", "country_code"]}
             } == relationship
    end

    test "Parse settings in long form relationship" do
      dbml =
        "Ref {
          users.id < reviews.user_id [on_delete: set null , on_update: cascade]
        }"

      assert {:ok, [relationship]} = Parser.parse_relationships(dbml)

      assert %Relationship{
               source: %RelationshipTable{name: "users", columns: ["id"]},
               relationship_type: :one_to_many,
               target: %RelationshipTable{name: "reviews", columns: ["user_id"]},
               settings: %RelationshipSettings{on_delete: :set_null, on_update: :cascade}
             } == relationship
    end
  end

  describe "Parse comments" do
    test "Parse single line comments in short form relationship" do
      dbml = ~S(
        // standalone comment
        Ref spaced_rel_name : users.id < reviews.user_id // comment
        Ref rel_name: users.post_id <> posts.id // comment
        Ref "quoted rel name": users.group_id > groups.id // comment
        Ref: marketing.contacts.id - accounts.users.contact_id // comment
      )

      assert {:ok, relationships} = Parser.parse_relationships(dbml)

      assert [
               %Relationship{
                 name: "spaced_rel_name",
                 source: %RelationshipTable{name: "users", columns: ["id"]},
                 relationship_type: :one_to_many,
                 target: %RelationshipTable{name: "reviews", columns: ["user_id"]}
               },
               %Relationship{
                 name: "rel_name",
                 source: %RelationshipTable{name: "users", columns: ["post_id"]},
                 relationship_type: :many_to_many,
                 target: %RelationshipTable{name: "posts", columns: ["id"]}
               },
               %Relationship{
                 name: "quoted rel name",
                 source: %RelationshipTable{name: "users", columns: ["group_id"]},
                 relationship_type: :many_to_one,
                 target: %RelationshipTable{name: "groups", columns: ["id"]}
               },
               %Relationship{
                 source: %RelationshipTable{
                   schema: "marketing",
                   name: "contacts",
                   columns: ["id"]
                 },
                 relationship_type: :one_to_one,
                 target: %RelationshipTable{
                   schema: "accounts",
                   name: "users",
                   columns: ["contact_id"]
                 }
               }
             ] == relationships
    end

    test "Parse multi line comments in short form relationship" do
      dbml = ~S(
        /* standalone comment */
        /**/ Ref /**/ spaced_rel_name /**/ : /**/ users.id /**/ < /**/ reviews.user_id /**/ /**/
        /**/ Ref /**/ rel_name /**/: /**/ users.post_id /**/ <> /**/ posts.id /**/ /**/
        /**/ Ref /**/ "quoted rel name" /**/: /**/ users.group_id /**/ > /**/ groups.id /**/ /**/
        /**/ Ref /**/: /**/ marketing.contacts.id /**/ - /**/ accounts.users.contact_id /**/ /**/
      )

      assert {:ok, relationships} = Parser.parse_relationships(dbml)

      assert [
               %Relationship{
                 name: "spaced_rel_name",
                 source: %RelationshipTable{name: "users", columns: ["id"]},
                 relationship_type: :one_to_many,
                 target: %RelationshipTable{name: "reviews", columns: ["user_id"]}
               },
               %Relationship{
                 name: "rel_name",
                 source: %RelationshipTable{name: "users", columns: ["post_id"]},
                 relationship_type: :many_to_many,
                 target: %RelationshipTable{name: "posts", columns: ["id"]}
               },
               %Relationship{
                 name: "quoted rel name",
                 source: %RelationshipTable{name: "users", columns: ["group_id"]},
                 relationship_type: :many_to_one,
                 target: %RelationshipTable{name: "groups", columns: ["id"]}
               },
               %Relationship{
                 source: %RelationshipTable{
                   schema: "marketing",
                   name: "contacts",
                   columns: ["id"]
                 },
                 relationship_type: :one_to_one,
                 target: %RelationshipTable{
                   schema: "accounts",
                   name: "users",
                   columns: ["contact_id"]
                 }
               }
             ] == relationships
    end

    test "Parse single line comments in long form relationships" do
      dbml = ~S(
        // standalone comment

        Ref spaced_rel_name { // comment
          users.id < reviews.user_id // comment
        } // comment

        Ref rel_name { // comment
          users.post_id <> posts.id // comment
        } // comment

        Ref "quoted rel name" { // comment
          users.group_id > groups.id // comment
        } // comment

        Ref { // comment
          marketing.contacts.id - users.contact_id // comment
        } // comment
      )

      assert {:ok, relationships} = Parser.parse_relationships(dbml)

      assert [
               %Relationship{
                 name: "spaced_rel_name",
                 source: %RelationshipTable{name: "users", columns: ["id"]},
                 relationship_type: :one_to_many,
                 target: %RelationshipTable{name: "reviews", columns: ["user_id"]}
               },
               %Relationship{
                 name: "rel_name",
                 source: %RelationshipTable{name: "users", columns: ["post_id"]},
                 relationship_type: :many_to_many,
                 target: %RelationshipTable{name: "posts", columns: ["id"]}
               },
               %Relationship{
                 name: "quoted rel name",
                 source: %RelationshipTable{name: "users", columns: ["group_id"]},
                 relationship_type: :many_to_one,
                 target: %RelationshipTable{name: "groups", columns: ["id"]}
               },
               %Relationship{
                 source: %RelationshipTable{
                   schema: "marketing",
                   name: "contacts",
                   columns: ["id"]
                 },
                 relationship_type: :one_to_one,
                 target: %RelationshipTable{name: "users", columns: ["contact_id"]}
               }
             ] == relationships
    end

    test "Parse multi line comments in long form relationships" do
      dbml = ~S(
        /* standalone comment */

        /**/ Ref /**/ spaced_rel_name /**/ { /**/
          /**/ users.id /**/ < /**/ reviews.user_id /**/
        /**/ } /**/

        /**/ Ref /**/ rel_name /**/ { /**/
          /**/ users.post_id /**/ <> /**/ posts.id /**/
        /**/ } /**/

        /**/ Ref /**/ "quoted rel name" /**/ { /**/
          /**/ users.group_id /**/ > /**/ groups.id /**/
        /**/ } /**/

        /**/ Ref /**/ { /**/
          /**/ marketing.contacts.id /**/ - /**/ users.contact_id /**/
        /**/ } /**/
      )

      assert {:ok, relationships} = Parser.parse_relationships(dbml)

      assert [
               %Relationship{
                 name: "spaced_rel_name",
                 source: %RelationshipTable{name: "users", columns: ["id"]},
                 relationship_type: :one_to_many,
                 target: %RelationshipTable{name: "reviews", columns: ["user_id"]}
               },
               %Relationship{
                 name: "rel_name",
                 source: %RelationshipTable{name: "users", columns: ["post_id"]},
                 relationship_type: :many_to_many,
                 target: %RelationshipTable{name: "posts", columns: ["id"]}
               },
               %Relationship{
                 name: "quoted rel name",
                 source: %RelationshipTable{name: "users", columns: ["group_id"]},
                 relationship_type: :many_to_one,
                 target: %RelationshipTable{name: "groups", columns: ["id"]}
               },
               %Relationship{
                 source: %RelationshipTable{
                   schema: "marketing",
                   name: "contacts",
                   columns: ["id"]
                 },
                 relationship_type: :one_to_one,
                 target: %RelationshipTable{name: "users", columns: ["contact_id"]}
               }
             ] == relationships
    end
  end
end

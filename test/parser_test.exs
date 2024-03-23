defmodule ExDbml.ParserTest do
  @moduledoc false
  use ExUnit.Case, async: true
  alias ExDbml.Parser

  test "Parse advanced sample from dbdiagram.io" do
    assert {:ok,
            [
              %ExDbml.Structs.Table{
                schema: "ecommerce",
                name: "merchants",
                columns: [
                  %ExDbml.Structs.TableColumn{
                    name: "id",
                    type: %ExDbml.Structs.TableColumnType{name: "int"}
                  },
                  %ExDbml.Structs.TableColumn{
                    name: "country_code",
                    type: %ExDbml.Structs.TableColumnType{name: "int"}
                  },
                  %ExDbml.Structs.TableColumn{
                    name: "merchant_name",
                    type: %ExDbml.Structs.TableColumnType{name: "varchar"}
                  },
                  %ExDbml.Structs.TableColumn{
                    name: "created at",
                    type: %ExDbml.Structs.TableColumnType{name: "varchar"}
                  },
                  %ExDbml.Structs.TableColumn{
                    name: "admin_id",
                    type: %ExDbml.Structs.TableColumnType{name: "int"},
                    settings: %ExDbml.Structs.TableColumnSettings{
                      unique: false,
                      increment: false,
                      relationships: [
                        %ExDbml.Structs.InlineRelationship{
                          relationship_type: :many_to_one,
                          target: %ExDbml.Structs.RelationshipTable{
                            name: "U",
                            columns: ["id"]
                          }
                        }
                      ]
                    }
                  }
                ],
                indexes: [
                  %ExDbml.Structs.TableIndex{
                    fields: ["id", "country_code"],
                    settings: %ExDbml.Structs.TableIndexSettings{
                      pk: true,
                      unique: false
                    }
                  }
                ]
              },
              %ExDbml.Structs.Table{
                name: "users",
                alias: "U",
                columns: [
                  %ExDbml.Structs.TableColumn{
                    name: "id",
                    type: %ExDbml.Structs.TableColumnType{name: "int"},
                    settings: %ExDbml.Structs.TableColumnSettings{
                      pk: true,
                      unique: false,
                      increment: true
                    }
                  },
                  %ExDbml.Structs.TableColumn{
                    name: "full_name",
                    type: %ExDbml.Structs.TableColumnType{name: "varchar"}
                  },
                  %ExDbml.Structs.TableColumn{
                    name: "created_at",
                    type: %ExDbml.Structs.TableColumnType{name: "timestamp"}
                  },
                  %ExDbml.Structs.TableColumn{
                    name: "country_code",
                    type: %ExDbml.Structs.TableColumnType{name: "int"}
                  }
                ]
              },
              %ExDbml.Structs.Table{
                name: "countries",
                columns: [
                  %ExDbml.Structs.TableColumn{
                    name: "code",
                    type: %ExDbml.Structs.TableColumnType{name: "int"},
                    settings: %ExDbml.Structs.TableColumnSettings{
                      pk: true,
                      unique: false,
                      increment: false
                    }
                  },
                  %ExDbml.Structs.TableColumn{
                    name: "name",
                    type: %ExDbml.Structs.TableColumnType{name: "varchar"}
                  },
                  %ExDbml.Structs.TableColumn{
                    name: "continent_name",
                    type: %ExDbml.Structs.TableColumnType{name: "varchar"}
                  }
                ]
              },
              %ExDbml.Structs.Relationship{
                source: %ExDbml.Structs.RelationshipTable{
                  name: "U",
                  columns: ["country_code"]
                },
                relationship_type: :many_to_one,
                target: %ExDbml.Structs.RelationshipTable{
                  name: "countries",
                  columns: ["code"]
                }
              },
              %ExDbml.Structs.Relationship{
                source: %ExDbml.Structs.RelationshipTable{
                  schema: "ecommerce",
                  name: "merchants",
                  columns: ["country_code"]
                },
                relationship_type: :many_to_one,
                target: %ExDbml.Structs.RelationshipTable{
                  name: "countries",
                  columns: ["code"]
                }
              },
              %ExDbml.Structs.Table{
                schema: "ecommerce",
                name: "order_items",
                columns: [
                  %ExDbml.Structs.TableColumn{
                    name: "order_id",
                    type: %ExDbml.Structs.TableColumnType{name: "int"},
                    settings: %ExDbml.Structs.TableColumnSettings{
                      unique: false,
                      increment: false,
                      relationships: [
                        %ExDbml.Structs.InlineRelationship{
                          relationship_type: :many_to_one,
                          target: %ExDbml.Structs.RelationshipTable{
                            schema: "ecommerce",
                            name: "orders",
                            columns: ["id"]
                          }
                        }
                      ]
                    }
                  },
                  %ExDbml.Structs.TableColumn{
                    name: "product_id",
                    type: %ExDbml.Structs.TableColumnType{name: "int"}
                  },
                  %ExDbml.Structs.TableColumn{
                    name: "quantity",
                    type: %ExDbml.Structs.TableColumnType{name: "int"},
                    settings: %ExDbml.Structs.TableColumnSettings{
                      default: 1,
                      unique: false,
                      increment: false
                    }
                  }
                ]
              },
              %ExDbml.Structs.Relationship{
                source: %ExDbml.Structs.RelationshipTable{
                  schema: "ecommerce",
                  name: "order_items",
                  columns: ["product_id"]
                },
                relationship_type: :many_to_one,
                target: %ExDbml.Structs.RelationshipTable{
                  schema: "ecommerce",
                  name: "products",
                  columns: ["id"]
                }
              },
              %ExDbml.Structs.Table{
                schema: "ecommerce",
                name: "orders",
                columns: [
                  %ExDbml.Structs.TableColumn{
                    name: "id",
                    type: %ExDbml.Structs.TableColumnType{name: "int"},
                    settings: %ExDbml.Structs.TableColumnSettings{
                      pk: true,
                      unique: false,
                      increment: false
                    }
                  },
                  %ExDbml.Structs.TableColumn{
                    name: "user_id",
                    type: %ExDbml.Structs.TableColumnType{name: "int"},
                    settings: %ExDbml.Structs.TableColumnSettings{
                      not_null: true,
                      unique: true,
                      increment: false
                    }
                  },
                  %ExDbml.Structs.TableColumn{
                    name: "status",
                    type: %ExDbml.Structs.TableColumnType{name: "varchar"}
                  },
                  %ExDbml.Structs.TableColumn{
                    name: "created_at",
                    type: %ExDbml.Structs.TableColumnType{name: "varchar"},
                    settings: %ExDbml.Structs.TableColumnSettings{
                      note: "When order created",
                      unique: false,
                      increment: false
                    }
                  }
                ]
              },
              %ExDbml.Structs.Enum{
                schema: "ecommerce",
                name: "products_status",
                values: [
                  %ExDbml.Structs.EnumValue{name: "out_of_stock"},
                  %ExDbml.Structs.EnumValue{name: "in_stock"},
                  %ExDbml.Structs.EnumValue{name: "running_low", note: "less than 20"}
                ]
              },
              %ExDbml.Structs.Table{
                schema: "ecommerce",
                name: "products",
                columns: [
                  %ExDbml.Structs.TableColumn{
                    name: "id",
                    type: %ExDbml.Structs.TableColumnType{name: "int"},
                    settings: %ExDbml.Structs.TableColumnSettings{
                      pk: true,
                      unique: false,
                      increment: false
                    }
                  },
                  %ExDbml.Structs.TableColumn{
                    name: "name",
                    type: %ExDbml.Structs.TableColumnType{name: "varchar"}
                  },
                  %ExDbml.Structs.TableColumn{
                    name: "merchant_id",
                    type: %ExDbml.Structs.TableColumnType{name: "int"},
                    settings: %ExDbml.Structs.TableColumnSettings{
                      not_null: true,
                      unique: false,
                      increment: false
                    }
                  },
                  %ExDbml.Structs.TableColumn{
                    name: "price",
                    type: %ExDbml.Structs.TableColumnType{name: "int"}
                  },
                  %ExDbml.Structs.TableColumn{
                    name: "status",
                    type: %ExDbml.Structs.TableColumnType{
                      name: "ecommerceproducts_status"
                    }
                  },
                  %ExDbml.Structs.TableColumn{
                    name: "created_at",
                    type: %ExDbml.Structs.TableColumnType{name: "datetime"},
                    settings: %ExDbml.Structs.TableColumnSettings{
                      default: "now()",
                      unique: false,
                      increment: false
                    }
                  }
                ],
                indexes: [
                  %ExDbml.Structs.TableIndex{
                    fields: ["merchant_id", "status"],
                    settings: %ExDbml.Structs.TableIndexSettings{
                      name: "product_status",
                      pk: false,
                      unique: false
                    }
                  },
                  %ExDbml.Structs.TableIndex{
                    fields: ["id"],
                    settings: %ExDbml.Structs.TableIndexSettings{
                      pk: false,
                      unique: true
                    }
                  }
                ]
              },
              %ExDbml.Structs.Table{
                schema: "ecommerce",
                name: "product_tags",
                columns: [
                  %ExDbml.Structs.TableColumn{
                    name: "id",
                    type: %ExDbml.Structs.TableColumnType{name: "int"},
                    settings: %ExDbml.Structs.TableColumnSettings{
                      pk: true,
                      unique: false,
                      increment: false
                    }
                  },
                  %ExDbml.Structs.TableColumn{
                    name: "name",
                    type: %ExDbml.Structs.TableColumnType{name: "varchar"}
                  }
                ]
              },
              %ExDbml.Structs.Table{
                schema: "ecommerce",
                name: "merchant_periods",
                columns: [
                  %ExDbml.Structs.TableColumn{
                    name: "id",
                    type: %ExDbml.Structs.TableColumnType{name: "int"},
                    settings: %ExDbml.Structs.TableColumnSettings{
                      pk: true,
                      unique: false,
                      increment: false
                    }
                  },
                  %ExDbml.Structs.TableColumn{
                    name: "merchant_id",
                    type: %ExDbml.Structs.TableColumnType{name: "int"}
                  },
                  %ExDbml.Structs.TableColumn{
                    name: "country_code",
                    type: %ExDbml.Structs.TableColumnType{name: "int"}
                  },
                  %ExDbml.Structs.TableColumn{
                    name: "start_date",
                    type: %ExDbml.Structs.TableColumnType{name: "datetime"}
                  },
                  %ExDbml.Structs.TableColumn{
                    name: "end_date",
                    type: %ExDbml.Structs.TableColumnType{name: "datetime"}
                  }
                ]
              },
              %ExDbml.Structs.Relationship{
                source: %ExDbml.Structs.RelationshipTable{
                  schema: "ecommerce",
                  name: "products",
                  columns: ["merchant_id"]
                },
                relationship_type: :many_to_one,
                target: %ExDbml.Structs.RelationshipTable{
                  schema: "ecommerce",
                  name: "merchants",
                  columns: ["id"]
                }
              },
              %ExDbml.Structs.Relationship{
                source: %ExDbml.Structs.RelationshipTable{
                  schema: "ecommerce",
                  name: "product_tags",
                  columns: ["id"]
                },
                relationship_type: :many_to_many,
                target: %ExDbml.Structs.RelationshipTable{
                  schema: "ecommerce",
                  name: "products",
                  columns: ["id"]
                }
              },
              %ExDbml.Structs.Relationship{
                source: %ExDbml.Structs.RelationshipTable{
                  schema: "ecommerce",
                  name: "merchant_periods",
                  columns: ["merchant_id", "country_code"]
                },
                relationship_type: :many_to_one,
                target: %ExDbml.Structs.RelationshipTable{
                  schema: "ecommerce",
                  name: "merchants",
                  columns: ["id", "country_code"]
                }
              }
            ]} == Parser.parse(dbml())
  end

  defp dbml do
    """
    //// Docs: https://dbml.dbdiagram.io/docs
    //// -- LEVEL 1
    //// -- Schemas, Tables and References

    // Creating tables
    // You can define the tables with full schema names
    Table ecommerce.merchants {
      id int
      country_code int
      merchant_name varchar

      "created at" varchar
      admin_id int [ref: > U.id]
      Indexes {
      (id, country_code) [pk]
      }
    }

    // If schema name is omitted, it will default to "public" schema.
    Table users as U {
      id int [pk, increment] // auto-increment
      full_name varchar
      created_at timestamp
      country_code int
    }

    Table countries {
      code int [pk]
      name varchar
      continent_name varchar
    }

    // Creating references
    // You can also define relaionship separately
    // > many-to-one; < one-to-many; - one-to-one; <> many-to-many
    Ref: U.country_code > countries.code
    Ref: ecommerce.merchants.country_code > countries.code

    //----------------------------------------------//

    //// -- LEVEL 2
    //// -- Adding column settings

    Table ecommerce.order_items {
      order_id int [ref: > ecommerce.orders.id] // inline relationship (many-to-one)
      product_id int
      quantity int [default: 1] // default value
    }

    Ref: ecommerce.order_items.product_id > ecommerce.products.id

    Table ecommerce.orders {
      id int [pk] // primary key
      user_id int [not null, unique]
      status varchar
      created_at varchar [note: 'When order created'] // add column note
    }

    //----------------------------------------------//

    //// -- Level 3
    //// -- Enum, Indexes

    // Enum for 'products' table below
    Enum ecommerce.products_status {
      out_of_stock
      in_stock
      running_low [note: 'less than 20'] // add column note
    }

    // Indexes: You can define a single or multi-column index
    Table ecommerce.products {
      id int [pk]
      name varchar
      merchant_id int [not null]
      price int
      status ecommerce.products_status
      created_at datetime [default: `now()`]

      Indexes {
        (merchant_id, status) [name:'product_status']
        id [unique]
      }
    }

    Table ecommerce.product_tags {
      id int [pk]
      name varchar
    }

    Table ecommerce.merchant_periods {
      id int [pk]
      merchant_id int
      country_code int
      start_date datetime
      end_date datetime
    }

    Ref: ecommerce.products.merchant_id > ecommerce.merchants.id // many-to-one
    Ref: ecommerce.product_tags.id <> ecommerce.products.id // many-to-many
    //composite foreign key
    Ref: ecommerce.merchant_periods.(merchant_id, country_code) > ecommerce.merchants.(id, country_code)

    """
  end
end

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180228172436) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "shopify_collects", id: :bigint, default: nil, force: :cascade do |t|
    t.bigint "collection_id"
    t.datetime "created_at"
    t.boolean "featured"
    t.integer "position"
    t.bigint "product_id"
    t.string "sort_value"
    t.datetime "updated_at"
  end

  create_table "shopify_custom_collections", id: :bigint, default: nil, force: :cascade do |t|
    t.text "body_html"
    t.string "handle"
    t.string "image"
    t.json "metafield"
    t.boolean "published"
    t.datetime "published_at"
    t.string "published_scope"
    t.string "sort_order"
    t.string "template_suffix"
    t.string "title"
    t.datetime "updated_at"
  end

  create_table "shopify_product_variants", id: :bigint, default: nil, force: :cascade do |t|
    t.string "barcode"
    t.float "compare_at_price"
    t.datetime "created_at"
    t.string "fulfillment_service"
    t.integer "grams"
    t.bigint "image_id"
    t.string "inventory_management"
    t.string "inventory_policy"
    t.integer "inventory_quantity"
    t.integer "old_inventory_quantity"
    t.integer "inventory_quantity_adjustment"
    t.bigint "inventory_item_id"
    t.boolean "requires_shipping"
    t.json "metafield"
    t.string "option1"
    t.string "option2"
    t.string "option3"
    t.integer "position"
    t.float "price"
    t.bigint "product_id"
    t.string "sku"
    t.boolean "taxable"
    t.string "tax_code"
    t.string "title"
    t.datetime "updated_at"
    t.integer "weight"
    t.string "weight_unit"
  end

  create_table "shopify_products", id: :bigint, default: nil, force: :cascade do |t|
    t.text "body_html"
    t.datetime "created_at"
    t.string "handle"
    t.json "image"
    t.json "images"
    t.json "options"
    t.string "product_type"
    t.datetime "published_at"
    t.string "published_scope"
    t.string "tags"
    t.string "template_suffix"
    t.string "title"
    t.string "metafields_global_title_tag"
    t.string "metafields_global_description_tag"
    t.datetime "updated_at"
    t.json "variants"
    t.string "vendor"
  end

end

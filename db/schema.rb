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

  create_table "collects", force: :cascade do |t|
    t.string "site_id"
    t.string "collection_id"
    t.string "product_id"
    t.boolean "featured"
    t.integer "position"
  end

  create_table "custom_collections", force: :cascade do |t|
    t.string "site_id"
    t.string "handle"
    t.string "title"
    t.string "body_html"
    t.string "sort_order"
    t.string "template_suffix"
    t.string "published_scope"
  end

  create_table "product_variants", force: :cascade do |t|
    t.string "site_id"
    t.string "product_id"
    t.string "title"
    t.string "barcode"
    t.string "fulfillment_service"
    t.integer "grams"
    t.string "image_id"
    t.string "inventory_item_id"
    t.string "inventory_management"
    t.string "inventory_policy"
    t.integer "old_inventory_quantity"
    t.string "options", array: true
    t.integer "position"
    t.string "price"
    t.integer "weight"
    t.string "weight_unit"
    t.boolean "requires_shipping"
    t.string "sku"
    t.string "taxable"
  end

  create_table "products", force: :cascade do |t|
    t.string "site_id"
    t.string "title", null: false
    t.string "handle"
    t.string "body_html", default: ""
    t.string "vendor"
    t.string "product_type", default: ""
    t.string "template_suffix"
    t.string "published_scope"
    t.string "tags", array: true
    t.jsonb "images"
    t.jsonb "image"
  end

end

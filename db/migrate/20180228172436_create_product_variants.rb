class CreateProductVariants < ActiveRecord::Migration[5.1]
  def change
    create_table :shopify_product_variants, id: false do |t|
      t.bigint :id, null: false, primary_key: true
      t.string :barcode
      t.float :compare_at_price
      t.timestamp :created_at
      t.string :fulfillment_service
      t.integer :grams
      t.bigint :image_id
      t.string :inventory_management
      t.string :inventory_policy
      t.integer :inventory_quantity
      t.integer :old_inventory_quantity
      t.integer :inventory_quantity_adjustment
      t.bigint :inventory_item_id
      t.boolean :requires_shipping
      t.json :metafield
      t.string :option1
      t.string :option2
      t.string :option3
      t.integer :position
      t.float :price
      t.bigint :product_id
      t.string :sku
      t.boolean :taxable
      t.string :tax_code
      t.string :title
      t.timestamp :updated_at
      t.integer :weight
      t.string :weight_unit
    end
  end
end

class CreateProductVariants < ActiveRecord::Migration[5.1]
  def change
    create_table :product_variants do |t|
      t.string :site_id
      t.string :product_id # join with Product.site_id
      t.string :title # Usually size i.e. XS, L, etc..
      t.string :barcode
      t.string :fulfillment_service
      t.integer :grams
      t.string :image_id
      t.string :inventory_item_id
      t.string :inventory_management
      t.string :inventory_policy
      t.integer :old_inventory_quantity
      t.string :options, array: true
      t.integer :position
      t.string :price
      t.integer :weight
      t.string :weight_unit
      t.boolean :requires_shipping
      t.string :sku
      t.string :taxable
    end
  end
end

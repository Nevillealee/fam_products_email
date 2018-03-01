class CreateCollects < ActiveRecord::Migration[5.1]
  def change
    create_table :shopify_collects, id: false do |t|
      t.bigint :id, null: false, primary_key: true
      t.bigint :collection_id
      t.timestamp :created_at
      t.boolean :featured
      t.integer :position
      t.bigint :product_id
      t.string :sort_value
      t.timestamp :updated_at
    end
  end
end

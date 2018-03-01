class CreateProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :shopify_products, id: false do |t|
      t.bigint :id, null: false, primary_key: true
      t.text :body_html
      t.timestamp :created_at
      t.string :handle
      t.json :image
      t.json :images
      t.json :options
      t.string :product_type
      t.timestamp :published_at
      t.string :published_scope
      t.string :tags
      t.string :template_suffix
      t.string :title
      t.string :metafields_global_title_tag
      t.string :metafields_global_description_tag
      t.timestamp :updated_at
      t.json :variants
     t.string :vendor
    end
  end
end

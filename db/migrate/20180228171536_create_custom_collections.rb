class CreateCustomCollections < ActiveRecord::Migration[5.1]
  def change
    create_table :shopify_custom_collections, id: false do |t|
      t.bigint :id, null: false, primary_key: true
      t.text :body_html
      t.string :handle
      t.string :image
      t.json :metafield
      t.boolean :published
      t.timestamp :published_at
      t.string :published_scope
      t.string :sort_order
      t.string :template_suffix
      t.string :title
      t.timestamp :updated_at
    end
  end
end

class CreateProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :products do |t|
      t.string :site_id #id on api, renamed because of active record
      t.string :title, null: false
      t.string :handle
      t.string :body_html, default: ''
      t.string :vendor
      t.string :product_type, default: ''
      t.string :template_suffix
      t.string :published_scope
      t.string :tags, array: true
      t.jsonb :images
      t.jsonb :image
    end
  end
end

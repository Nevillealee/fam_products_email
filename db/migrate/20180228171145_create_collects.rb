class CreateCollects < ActiveRecord::Migration[5.1]
  def change
    create_table :collects do |t|
      t.string :site_id #id on api, renamed because of active record
      t.string :collection_id
      t.string :product_id
      t.boolean :featured
      t.integer :position
    end
  end
end

class CreateSubLineItmes < ActiveRecord::Migration[5.1]
  def change
    create_table :sub_line_items do |t|
      t.string :subscription_id
      t.string :name
      t.string :value
      t.references :subscription, index: true
    end
  end
end

class CreateCustomers < ActiveRecord::Migration[5.1]
  def change
    create_table :customers do |t|
      t.string :customer_id
      t.string :customer_hash
      t.string :shopify_customer_id
      t.string :email
      t.datetime :created_at
      t.datetime :updated_at
      t.string :first_name
      t.string :last_name
      t.string :billing_address1
      t.string :billing_address2
      t.string :billing_zip
      t.string :billing_city
      t.string :billing_company
      t.string :billing_province
      t.string :billing_country
      t.string :billing_phone
      t.string :processor_type
      t.string :status
      t.datetime :synced_at
      t.references :customer, index: true
      t.references :shopify_customer, index: true
    end
  end
end

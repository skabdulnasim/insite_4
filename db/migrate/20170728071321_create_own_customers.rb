class CreateOwnCustomers < ActiveRecord::Migration
  def change
    create_table :own_customers do |t|
      t.string :name
      t.string :customer_unique_id
      t.string :mobile_no
      t.string :email

      t.timestamps
    end
  end
end

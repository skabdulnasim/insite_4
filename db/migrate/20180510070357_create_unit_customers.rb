class CreateUnitCustomers < ActiveRecord::Migration
  def change
    create_table :unit_customers do |t|
      t.integer :unit_id
      t.integer :customer_id

      t.timestamps
    end
  end
end

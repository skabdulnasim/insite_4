class CreateCustomerCommunications < ActiveRecord::Migration
  def change
    create_table :customer_communications do |t|
      t.integer :customer_id
      t.integer :user_id
      t.string :communication_medium
      t.text :communication_details
      t.datetime :recorded_at

      t.timestamps
    end
  end
end

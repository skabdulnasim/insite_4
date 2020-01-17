class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :table_id
      t.integer :bill_id
      t.integer :status_id
      t.integer :user_id

      t.timestamps
    end
  end
end

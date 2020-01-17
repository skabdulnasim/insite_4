class CreateBillOrders < ActiveRecord::Migration
  def change
    create_table :bill_orders do |t|
      t.integer :bill_id
      t.integer :order_id

      t.timestamps
    end
  end
end

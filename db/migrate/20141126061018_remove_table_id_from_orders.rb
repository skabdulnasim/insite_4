class RemoveTableIdFromOrders < ActiveRecord::Migration
  def up
    remove_column :orders, :table_id, :bill_id
  end

  def down
    remove_column :orders, :table_id, :bill_id
  end
end

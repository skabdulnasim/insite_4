class AddSlotIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :slot_id, :integer
  end
end

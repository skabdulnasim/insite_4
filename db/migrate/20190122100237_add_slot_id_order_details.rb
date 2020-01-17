class AddSlotIdOrderDetails < ActiveRecord::Migration
  def up
  	add_column :order_details, :slot_id, :integer
  end
end

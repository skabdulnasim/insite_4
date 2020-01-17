class AddLotIdToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :lot_id, :integer
    add_column :order_details, :lot_identification, :integer
  end
end

class AddExternalOrderIdToExternalOrders < ActiveRecord::Migration
  def change
    add_column :external_orders, :external_order_id, :integer
  end
end

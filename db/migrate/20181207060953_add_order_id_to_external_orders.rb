class AddOrderIdToExternalOrders < ActiveRecord::Migration
  def change
  	add_column :external_orders, :order_id, :integer
  end
end

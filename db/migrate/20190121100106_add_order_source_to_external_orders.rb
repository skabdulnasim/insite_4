class AddOrderSourceToExternalOrders < ActiveRecord::Migration
  def change
    add_column :external_orders, :order_source, :string
  end
end

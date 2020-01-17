class AddResourceTypeToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :resource_type, :string
  end
end

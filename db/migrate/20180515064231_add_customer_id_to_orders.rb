class AddCustomerIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :customer_id, :integer
    add_column :orders, :latitude, :string
    add_column :orders, :longitude, :string
  end
end

class AddAddressIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :address_id, :integer
    add_column :inspections, :address_id, :integer
    add_column :visiting_histories, :address_id, :integer
  end
end

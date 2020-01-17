class AddUnitIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :unit_id, :integer
  end
end

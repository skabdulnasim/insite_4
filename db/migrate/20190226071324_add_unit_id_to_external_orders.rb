class AddUnitIdToExternalOrders < ActiveRecord::Migration
  def change
    add_column :external_orders, :unit_id, :integer
  end
end

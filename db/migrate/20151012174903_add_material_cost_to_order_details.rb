class AddMaterialCostToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :material_cost, :float
  end
end

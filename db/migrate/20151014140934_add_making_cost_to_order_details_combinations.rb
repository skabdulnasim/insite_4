class AddMakingCostToOrderDetailsCombinations < ActiveRecord::Migration
  def change
    add_column :order_detail_combinations, :material_cost, :float, default: 0
  end
end

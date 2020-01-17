class AddUnitIdToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :unit_id, :integer
    add_column :order_detail_combinations, :unit_id, :integer
    add_column :order_detail_combinations, :status, :string
  end
end

class AddUnitProductIdToLots < ActiveRecord::Migration
  def change
    add_column :lots, :unit_product_id, :integer
  end
end

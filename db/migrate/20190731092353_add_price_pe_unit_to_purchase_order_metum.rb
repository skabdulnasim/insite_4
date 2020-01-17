class AddPricePeUnitToPurchaseOrderMetum < ActiveRecord::Migration
  def change
    add_column :purchase_order_meta, :price_per_unit, :float
  end
end

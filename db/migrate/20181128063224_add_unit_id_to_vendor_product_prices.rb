class AddUnitIdToVendorProductPrices < ActiveRecord::Migration
  def change
    add_column :vendor_product_prices, :unit_id, :integer
  end
end

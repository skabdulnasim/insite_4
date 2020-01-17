class ChangeFieldNamesInVendorProductPrices < ActiveRecord::Migration
  def change
  	rename_column :vendor_product_prices, :viwed_by, :viewed_by
  	rename_column :vendor_product_prices, :reported_by, :visited_by
  end
end
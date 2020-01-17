class AddSourceLatitudeAndSourceLongitudeToVendorProductPrices < ActiveRecord::Migration
  def change
    add_column :vendor_product_prices, :source_latitude, :string
    add_column :vendor_product_prices, :source_longitude, :string
  end
end

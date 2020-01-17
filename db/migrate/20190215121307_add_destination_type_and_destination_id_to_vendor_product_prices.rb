class AddDestinationTypeAndDestinationIdToVendorProductPrices < ActiveRecord::Migration
  def change
  	add_column :vendor_product_prices, :destination_type, :string
    add_column :vendor_product_prices, :destination_id, :integer
  end
end
class AddRecordedAtToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :recorded_at, :datetime
    add_column :vendor_products, :recorded_at, :datetime
    add_column :vendor_product_prices, :recorded_at, :datetime
    add_column :vendor_contracts, :recorded_at, :datetime
  end
end

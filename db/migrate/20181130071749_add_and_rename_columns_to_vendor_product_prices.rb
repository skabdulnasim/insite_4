class AddAndRenameColumnsToVendorProductPrices < ActiveRecord::Migration
  def change
    add_column :vendor_product_prices, :total_tax_amount, :float
    add_column :vendor_product_prices, :total_price_with_tax, :float
    add_column :vendor_product_prices, :total_price_without_tax, :float
    add_column :vendor_product_prices, :subtotal, :float
    rename_column :vendor_product_prices, :price_without_tax, :unit_price_without_tax
    rename_column :vendor_product_prices, :price_with_tax, :unit_price_with_tax
  end
end

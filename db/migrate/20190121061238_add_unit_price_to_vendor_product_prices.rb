class AddUnitPriceToVendorProductPrices < ActiveRecord::Migration
  def change
    add_column :vendor_product_prices, :unit_price, :float
    add_column :vendor_product_prices, :tax_inclusion, :boolean
    add_column :vendor_product_prices, :delivery_charge_inclision, :boolean
    add_column :vendor_product_prices, :total_agreed_qty, :float
    add_column :vendor_product_prices, :supply_interval, :string
    add_column :vendor_product_prices, :source_location, :text
  end
end

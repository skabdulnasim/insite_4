class AddVendorContractIdToVendorProductPrices < ActiveRecord::Migration
  def change
    add_column :vendor_product_prices, :vendor_contract_id, :integer
  end
end

class RenameProductSkuToSku < ActiveRecord::Migration
  def up
  	rename_column :bin_products, :product_sku, :sku
  end

  def down
  	rename_column :bin_products, :sku, :product_sku
  end
end

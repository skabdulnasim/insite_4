class MigrateSkuToUniqueIdentityInOredrDetails < ActiveRecord::Migration
  def up
    if column_exists? :order_details, :sku
      OrderDetail.update_all("product_unique_identity=sku")
      remove_column :order_details, :sku
    end
  end

  def down
  end
end

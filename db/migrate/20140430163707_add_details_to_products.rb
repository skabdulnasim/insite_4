class AddDetailsToProducts < ActiveRecord::Migration
  def change
    add_column :products, :product_type, :string
    add_column :products, :sku, :string
  end
end

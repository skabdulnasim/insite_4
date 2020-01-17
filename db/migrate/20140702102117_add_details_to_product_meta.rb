class AddDetailsToProductMeta < ActiveRecord::Migration
  def change
    add_column :product_meta, :product_id, :integer
    add_column :product_meta, :meta_key, :string
  end
end

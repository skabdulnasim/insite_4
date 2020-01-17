class AddDefaultValueToProductSizeAttribute < ActiveRecord::Migration
  def change
  	change_column :product_sizes, :status, :integer, :default => 0
  end
end

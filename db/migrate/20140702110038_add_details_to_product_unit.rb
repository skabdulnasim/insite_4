class AddDetailsToProductUnit < ActiveRecord::Migration
  def change
    add_column :product_units, :short_name, :string
  end
end

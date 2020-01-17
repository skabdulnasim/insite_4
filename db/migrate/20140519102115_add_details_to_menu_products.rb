class AddDetailsToMenuProducts < ActiveRecord::Migration
  def change
    add_column :menu_products, :procured_price, :integer
    add_column :menu_products, :sell_price, :integer
  end
end

class AddStoctDetailsToMenuProducts < ActiveRecord::Migration
  def change
    add_column :menu_products, :stock_status, :integer
    add_column :menu_products, :stock_qty, :integer
  end
end

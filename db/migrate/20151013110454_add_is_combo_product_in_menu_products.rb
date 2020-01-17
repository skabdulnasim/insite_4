class AddIsComboProductInMenuProducts < ActiveRecord::Migration
  def up
    add_column :menu_products, :is_buffet_product, :boolean, default: false
  end

  def down
    remove_column :menu_products, :is_buffet_product
  end
end

class ChangeDefaultToIsdefaultToMenuProducts < ActiveRecord::Migration
  def up
    rename_column :menu_products, :default, :isdefault
  end

  def down
    rename_column :menu_products, :isdefault, :default
  end
end

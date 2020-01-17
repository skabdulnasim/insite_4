class AddModeToMenuProducts < ActiveRecord::Migration
  def change
    add_column :menu_products, :mode, :integer
  end
end

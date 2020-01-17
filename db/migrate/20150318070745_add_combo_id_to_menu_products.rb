class AddComboIdToMenuProducts < ActiveRecord::Migration
  def change
    add_column :menu_products, :combo_id, :integer
  end
end

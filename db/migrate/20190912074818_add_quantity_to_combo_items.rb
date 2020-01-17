class AddQuantityToComboItems < ActiveRecord::Migration
  def change
    add_column :combo_items, :quantity, :float
  end
end

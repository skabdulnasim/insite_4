class AddVariableIdToMenuProducts < ActiveRecord::Migration
  def change
    add_column :menu_products, :variable_id, :integer
  end
end

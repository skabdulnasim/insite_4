class AddTaxGroupIdInMenuProducts < ActiveRecord::Migration
  def change
    add_column :menu_products, :tax_group_id, :integer
  end
end

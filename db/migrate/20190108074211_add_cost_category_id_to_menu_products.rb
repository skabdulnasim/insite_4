class AddCostCategoryIdToMenuProducts < ActiveRecord::Migration
  def change
    add_column :menu_products, :cost_category_id, :integer
  end
end

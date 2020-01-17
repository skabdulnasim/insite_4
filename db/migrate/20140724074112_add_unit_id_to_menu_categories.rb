class AddUnitIdToMenuCategories < ActiveRecord::Migration
  def change
    add_column :menu_categories, :unit_id, :integer
  end
end

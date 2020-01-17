class AddRestRegNoToMenuCategories < ActiveRecord::Migration
  def change
    add_column :menu_categories, :rest_reg_no, :text
  end
end

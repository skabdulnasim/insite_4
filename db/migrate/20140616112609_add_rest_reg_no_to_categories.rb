class AddRestRegNoToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :rest_reg_no, :text
  end
end

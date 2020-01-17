class AddRestRegNoToMenuProducts < ActiveRecord::Migration
  def change
    add_column :menu_products, :rest_reg_no, :text
  end
end

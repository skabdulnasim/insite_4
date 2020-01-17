class AddRestRegNoToProductUnit < ActiveRecord::Migration
  def change
    add_column :product_units, :rest_reg_no, :text
  end
end

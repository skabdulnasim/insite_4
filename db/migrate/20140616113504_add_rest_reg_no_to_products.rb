class AddRestRegNoToProducts < ActiveRecord::Migration
  def change
    add_column :products, :rest_reg_no, :text
  end
end

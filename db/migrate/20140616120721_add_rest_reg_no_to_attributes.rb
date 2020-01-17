class AddRestRegNoToAttributes < ActiveRecord::Migration
  def change
    add_column :attributes, :rest_reg_no, :text
  end
end

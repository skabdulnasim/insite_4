class AddRestRegNoToUnits < ActiveRecord::Migration
  def change
    add_column :units, :rest_reg_no, :text
  end
end

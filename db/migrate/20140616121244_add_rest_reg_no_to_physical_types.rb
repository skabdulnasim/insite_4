class AddRestRegNoToPhysicalTypes < ActiveRecord::Migration
  def change
    add_column :physical_types, :rest_reg_no, :text
  end
end

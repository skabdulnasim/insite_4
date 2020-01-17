class AddRestRegNoToUnittypes < ActiveRecord::Migration
  def change
    add_column :unittypes, :rest_reg_no, :text
  end
end

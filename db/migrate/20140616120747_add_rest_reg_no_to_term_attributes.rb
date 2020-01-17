class AddRestRegNoToTermAttributes < ActiveRecord::Migration
  def change
    add_column :term_attributes, :rest_reg_no, :text
  end
end

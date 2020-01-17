class AddRestRegNoToUsers < ActiveRecord::Migration
  def change
    add_column :users, :rest_reg_no, :text
  end
end

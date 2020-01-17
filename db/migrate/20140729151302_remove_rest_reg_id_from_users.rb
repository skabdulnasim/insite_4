class RemoveRestRegIdFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :rest_reg_no
  end
end

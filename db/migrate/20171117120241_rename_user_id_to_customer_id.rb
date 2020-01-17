class RenameUserIdToCustomerId < ActiveRecord::Migration
  def change
  	rename_column :preauths, :user_id, :customer_id
  end
end

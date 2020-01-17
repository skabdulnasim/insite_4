class AddUserIdToPreauths < ActiveRecord::Migration
  def change
    add_column :preauths, :user_id, :integer
  end
end

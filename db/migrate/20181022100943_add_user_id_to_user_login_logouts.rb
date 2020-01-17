class AddUserIdToUserLoginLogouts < ActiveRecord::Migration
  def change
    add_column :user_login_logouts, :user_id, :integer
  end
end

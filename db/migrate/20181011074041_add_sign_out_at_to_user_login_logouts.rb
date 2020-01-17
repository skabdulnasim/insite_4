class AddSignOutAtToUserLoginLogouts < ActiveRecord::Migration
  def change
    add_column :user_login_logouts, :sign_out_at, :datetime
  end
end

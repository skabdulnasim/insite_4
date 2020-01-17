class AddSignInAtToUserLoginLogouts < ActiveRecord::Migration
  def change
    add_column :user_login_logouts, :sign_in_at, :datetime
  end
end

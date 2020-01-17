class RemoveLastSignInAtFromUserLoginLogout < ActiveRecord::Migration
  def up
    remove_column :user_login_logouts, :last_sign_in_at
  end

  def down
    add_column :user_login_logouts, :last_sign_in_at, :datetime
  end
end

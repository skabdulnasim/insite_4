class RemoveSignInCountFromUserLoginLogout < ActiveRecord::Migration
  def up
    remove_column :user_login_logouts, :sign_in_count
  end

  def down
    add_column :user_login_logouts, :sign_in_count, :integer
  end
end

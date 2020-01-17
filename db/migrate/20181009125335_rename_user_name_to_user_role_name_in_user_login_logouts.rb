class RenameUserNameToUserRoleNameInUserLoginLogouts < ActiveRecord::Migration
  def change
  	rename_column :user_login_logouts, :user_name, :user_role_name
  end
end

class RemoveColumnsFromUserLoginLogouts < ActiveRecord::Migration
  def up
    remove_column :user_login_logouts, :email
    remove_column :user_login_logouts, :firstname
    remove_column :user_login_logouts, :lastname
    remove_column :user_login_logouts, :contact_no
    remove_column :user_login_logouts, :address
  end

  def down
    add_column :user_login_logouts, :address, :string
    add_column :user_login_logouts, :contact_no, :string
    add_column :user_login_logouts, :lastname, :string
    add_column :user_login_logouts, :firstname, :string
    add_column :user_login_logouts, :email, :string
  end
end

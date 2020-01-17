class AddColumnsToUserLoginLogouts < ActiveRecord::Migration
  def change
    add_column :user_login_logouts, :email, :string
    add_column :user_login_logouts, :firstname, :string
    add_column :user_login_logouts, :lastname, :string
    add_column :user_login_logouts, :contact_no, :string
    add_column :user_login_logouts, :address, :text
    add_column :user_login_logouts, :unit_id, :integer
  end
end

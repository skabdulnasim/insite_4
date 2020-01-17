class AddUnitNameToUserLoginLogouts < ActiveRecord::Migration
  def change
    add_column :user_login_logouts, :unit_name, :string
  end
end

class AddDeviceIdentityToUserLoginLogouts < ActiveRecord::Migration
  def change
    add_column :user_login_logouts, :device_identity, :string
  end
end

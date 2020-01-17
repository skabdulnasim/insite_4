class AddDefaultValueToOrder < ActiveRecord::Migration
  def change
  	change_column :orders, :otp_status, :boolean, :default => false
  end
end

class AddOtpStatusToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :otp_status, :boolean
  end
end

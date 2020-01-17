class AddDeliverableOtpToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :deliverable_otp, :integer
  end
end

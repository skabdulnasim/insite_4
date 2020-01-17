class AddRecordedAtToPrePaypalPayments < ActiveRecord::Migration
  def change
    add_column :pre_paypal_payments, :recorded_at, :datetime
  end
end

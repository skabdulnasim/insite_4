class AddMobileNoToCustomerWalletTransaction < ActiveRecord::Migration
  def change
    add_column :customer_wallet_payments, :mobile_no, :string
  end
end

class AddAmountToPaytmPayments < ActiveRecord::Migration
  def change
    add_column :paytm_payments, :amount, :float
  end
end

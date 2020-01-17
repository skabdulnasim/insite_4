class ChangeColumnTypePrePaypalPayments < ActiveRecord::Migration
  def up
	change_column :pre_paypal_payments, :transaction_id, :string
  end
end

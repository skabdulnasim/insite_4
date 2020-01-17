class CreateWalletCashCreditModes < ActiveRecord::Migration
  def change
    create_table :wallet_cash_credit_modes do |t|
      t.float :amount
      t.string :remarks

      t.timestamps
    end
  end
end

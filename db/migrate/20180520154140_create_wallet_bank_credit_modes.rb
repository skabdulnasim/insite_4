class CreateWalletBankCreditModes < ActiveRecord::Migration
  def change
    create_table :wallet_bank_credit_modes do |t|
      t.float :amount
      t.string :bank_namy
      t.string :mode
      t.string :identity

      t.timestamps
    end
  end
end

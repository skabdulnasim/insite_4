class AddCreditModeReferenceToWalletTransaction < ActiveRecord::Migration
  def change
    add_column :wallet_transactions, :creditmode_id, :integer, index: true
    add_column :wallet_transactions, :creditmode_type, :string
  end
end

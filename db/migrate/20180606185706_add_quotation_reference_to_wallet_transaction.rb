class AddQuotationReferenceToWalletTransaction < ActiveRecord::Migration
  def change
    add_column :wallet_transactions, :quotation_id, :integer, null: true
  end
end

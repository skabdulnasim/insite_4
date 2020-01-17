class RenameTransactionsInPays < ActiveRecord::Migration
  def change
  	rename_column :pays, :transaction_id, :pay_transaction_id
  	rename_column :pays, :transaction_type, :pay_transaction_type
  end
end
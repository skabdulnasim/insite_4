class AddStatusToProductTransactionUnit < ActiveRecord::Migration
  def change
    add_column :product_transaction_units, :status, :boolean, :default => true
  end
end

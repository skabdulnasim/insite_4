class AddCurrencyCodeTransactionCurrencyDetails < ActiveRecord::Migration
  def up
  	add_column :transaction_currency_details, :currency_code, :string
  end
end

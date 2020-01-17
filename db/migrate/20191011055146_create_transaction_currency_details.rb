class CreateTransactionCurrencyDetails < ActiveRecord::Migration
  def change
    create_table :transaction_currency_details do |t|
      t.integer :currency_id
      t.integer :cash_id
      t.string :currency_name
      t.string :currency_symbol
      t.float :convertion_rate
      t.float :amount
      t.float :conversion_amount
      t.integer :accepted_currency_id
      t.timestamps
    end
  end
end

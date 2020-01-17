class CreateLoyaltyCreditTransactions < ActiveRecord::Migration
  def change
    create_table :loyalty_credit_transactions do |t|
      t.references :loyalty_card
      t.float :obtained_point
      t.float :obtained_money
      t.float :available_point
      t.float :available_money
      t.datetime :validity
      t.boolean :refundable
      t.string :remarks
      t.references :loyalty_credit
      t.string :loyalty_credit_type

      t.timestamps
    end
    add_index :loyalty_credit_transactions, :loyalty_card_id
    add_index :loyalty_credit_transactions, :loyalty_credit_id
  end
end

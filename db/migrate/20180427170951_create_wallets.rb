class CreateWallets < ActiveRecord::Migration
  def change
    create_table :wallets do |t|
      t.decimal :current_balance, precision: 6,scale: 2,default: 0.0, null: false
      t.decimal :total_credit, precision: 6,scale: 2,default: 0.0, null: false
      t.decimal :total_debit, precision: 6,scale: 2,default: 0.0, null: false
      t.references :customer

      t.timestamps
    end
    add_index :wallets, :customer_id
  end
end

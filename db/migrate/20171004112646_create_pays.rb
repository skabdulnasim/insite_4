class CreatePays < ActiveRecord::Migration
  def change
    create_table :pays do |t|
      t.float :amount
      t.integer :transaction_id
      t.string :transaction_type
      t.float :creadit_amount
      t.float :debit_amount
      t.integer :unit_id
      t.integer :user_id

      t.timestamps
    end
  end
end

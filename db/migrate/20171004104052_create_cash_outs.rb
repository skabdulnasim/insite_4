class CreateCashOuts < ActiveRecord::Migration
  def change
    create_table :cash_outs do |t|
      t.decimal :amount

      t.timestamps
    end
  end
end

class CreateCashIns < ActiveRecord::Migration
  def change
    create_table :cash_ins do |t|
      t.decimal :amount

      t.timestamps
    end
  end
end

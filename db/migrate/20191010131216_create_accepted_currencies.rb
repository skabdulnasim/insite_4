class CreateAcceptedCurrencies < ActiveRecord::Migration
  def change
    create_table :accepted_currencies do |t|
      t.integer :currency_id
      t.integer :multiplier
      t.boolean :status
      t.timestamps
    end
  end
end

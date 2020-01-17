class CreateCashDescriptions < ActiveRecord::Migration
  def change
    create_table :cash_descriptions do |t|
      t.integer :cash_id
      t.integer :count
      t.integer :denomination_id

      t.timestamps
    end
  end
end

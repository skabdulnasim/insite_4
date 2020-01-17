class CreateStockProductions < ActiveRecord::Migration
  def change
    create_table :stock_productions do |t|
      t.integer :kitchen_store_id
      t.integer :store_id
      t.string :status

      t.timestamps
    end
  end
end

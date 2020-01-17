class CreateStockRequisitions < ActiveRecord::Migration
  def change
    create_table :stock_requisitions do |t|
      t.integer :from_store
      t.integer :to_store

      t.timestamps
    end
  end
end

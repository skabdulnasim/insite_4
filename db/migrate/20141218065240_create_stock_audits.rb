class CreateStockAudits < ActiveRecord::Migration
  def change
    create_table :stock_audits do |t|
      t.integer :store_id
      t.string :status
      t.string :remarks
      t.timestamps
    end
  end
end

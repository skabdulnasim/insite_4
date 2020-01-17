class CreateKitchenProductionAudits < ActiveRecord::Migration
  def change
    create_table :kitchen_production_audits do |t|
      t.integer :product_id
      t.integer :store_id
      t.integer :stock_transfer_id
      t.float :received_qty
      t.float :procured_qty
      t.string :status
      t.text :remarks

      t.timestamps
    end
  end
end

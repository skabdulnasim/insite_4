class CreateLotSaleRules < ActiveRecord::Migration
  def change
    create_table :lot_sale_rules do |t|
      t.integer :lot_id
      t.integer :sale_rule_id

      t.timestamps
    end
  end
end

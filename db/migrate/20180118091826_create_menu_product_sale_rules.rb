class CreateMenuProductSaleRules < ActiveRecord::Migration
  def change
    create_table :menu_product_sale_rules do |t|
      t.integer :menu_product_id
      t.integer :sale_rule_id

      t.timestamps
    end
  end
end

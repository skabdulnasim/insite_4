class CreateMenuCategorySaleRules < ActiveRecord::Migration
  def change
    create_table :menu_category_sale_rules do |t|
      t.integer :menu_category_id
      t.integer :sale_rule_id

      t.timestamps
    end
  end
end

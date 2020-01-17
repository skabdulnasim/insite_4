class AddRuleIdToMenuProductCombinations < ActiveRecord::Migration
  def change
    add_column :menu_product_combinations, :combinations_rule_id, :integer
  end
end

class AddSaleRuleIdToSaleRuleOutputs < ActiveRecord::Migration
  def change
    add_column :sale_rule_outputs, :sale_rule_id, :integer
  end
end

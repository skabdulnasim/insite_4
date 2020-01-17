class AddSaleRuleIdToSaleRuleInputs < ActiveRecord::Migration
  def change
    add_column :sale_rule_inputs, :sale_rule_id, :integer
  end
end

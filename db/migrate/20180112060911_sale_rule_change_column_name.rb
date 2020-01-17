class SaleRuleChangeColumnName < ActiveRecord::Migration
  def up
  	rename_column :sale_rules, :type, :sale_rule_type
  	rename_column :sale_rule_inputs, :type, :sale_rule_input_type
  	rename_column :sale_rule_outputs, :type, :sale_rule_output_type
  end
end

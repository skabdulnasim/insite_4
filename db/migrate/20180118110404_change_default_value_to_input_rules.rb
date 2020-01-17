class ChangeDefaultValueToInputRules < ActiveRecord::Migration
  def up
  	change_column_default :sale_rule_inputs, :amount, 0
  	change_column_default :sale_rule_inputs, :buy_qty, 0
  	change_column_default :sale_rule_outputs, :amount, 0
  	change_column_default :sale_rule_outputs, :get_qty, 0
  end
end

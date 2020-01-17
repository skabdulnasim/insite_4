class AddGetQtyToSaleRuleOutputs < ActiveRecord::Migration
  def change
  	add_column :sale_rule_outputs, :get_qty, :integer
  end
end
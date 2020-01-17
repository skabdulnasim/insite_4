class AddAmountTypeToSaleRuleOutputs < ActiveRecord::Migration
  def change
    add_column :sale_rule_outputs, :amount_type, :string
  end
end

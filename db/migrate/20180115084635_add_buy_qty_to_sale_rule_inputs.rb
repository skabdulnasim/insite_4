class AddBuyQtyToSaleRuleInputs < ActiveRecord::Migration
  def change
    add_column :sale_rule_inputs, :buy_qty, :integer
  end
end

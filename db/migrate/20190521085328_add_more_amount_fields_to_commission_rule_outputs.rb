class AddMoreAmountFieldsToCommissionRuleOutputs < ActiveRecord::Migration
  def change
    add_column :commission_rule_outputs, :csm_commission_amount, :float
    add_column :commission_rule_outputs, :owner_commission_amount, :float
  end
end

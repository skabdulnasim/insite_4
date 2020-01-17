class CreateCommissionRuleOutputs < ActiveRecord::Migration
  def change
    create_table :commission_rule_outputs do |t|
      t.integer :commission_rule_id
      t.integer :commission_rule_input_id
      t.float :amount
      t.string :amount_type

      t.timestamps
    end
  end
end

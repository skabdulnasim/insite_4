class CreateSaleRuleOutputs < ActiveRecord::Migration
  def change
    create_table :sale_rule_outputs do |t|
      t.string :type
      t.float :amount

      t.timestamps
    end
  end
end

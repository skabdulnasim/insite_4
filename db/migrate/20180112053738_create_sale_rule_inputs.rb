class CreateSaleRuleInputs < ActiveRecord::Migration
  def change
    create_table :sale_rule_inputs do |t|
      t.string :type
      t.float :amount

      t.timestamps
    end
  end
end

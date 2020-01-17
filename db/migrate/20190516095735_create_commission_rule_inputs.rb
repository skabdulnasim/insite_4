class CreateCommissionRuleInputs < ActiveRecord::Migration
  def change
    create_table :commission_rule_inputs do |t|
      t.integer :commission_rule_id
      t.integer :product_id

      t.timestamps
    end
  end
end

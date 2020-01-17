class AddAvgIncentiveAmountToIncentiveRules < ActiveRecord::Migration
  def change
    add_column :incentive_rules, :avg_incentive_amount, :float
  end
end

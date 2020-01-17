class AddRechargeRuleToLoyaltyCardClass < ActiveRecord::Migration
  def change
    add_column    :loyalty_card_classes, :recharge_rule, :string, default: {:amount=> 1, :point=>1}
    rename_column :loyalty_card_classes, :purchase_rule, :enrollment_rule
  end
end

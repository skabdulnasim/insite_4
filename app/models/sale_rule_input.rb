class SaleRuleInput < ActiveRecord::Base
  attr_accessible :amount, :sale_rule_input_type, :buy_qty

  TYPE = %w(by_amount by_product by_lot)
end

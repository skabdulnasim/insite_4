class SaleRuleOutput < ActiveRecord::Base
  attr_accessible :amount, :sale_rule_output_type, :get_qty, :amount_type

  TYPE = %w(by_amount by_percentage by_product by_lot)
  AMOUNTTYPE = %w(by_amount by_percentage)
end

class CommissionRuleOutput < ActiveRecord::Base
  attr_accessible :amount, :csm_commission_amount, :owner_commission_amount, :amount_type, :commission_rule_id, :commission_rule_input_id

  # Model Relation
  belongs_to :commission_rule_input
  belongs_to :commission_rule

  # Model Callbacks
  after_create :set_commission_rule
  after_save  :modify_user_sale


  scope :by_resource_month_product, lambda {|resource_id,month,product_id|joins(:commission_rule).where("commission_rules.resource_id=? AND commission_rules.month=?", resource_id,month).joins(:commission_rule_input).where("commission_rule_inputs.product_id=?",product_id)}

  private

  def set_commission_rule
    update_attribute(:commission_rule_id, self.commission_rule_input.commission_rule_id)
    update_attribute(:amount, self.csm_commission_amount + self.owner_commission_amount)
  end

  def modify_user_sale
    resource_id = self.commission_rule.resource_id
    month_begn = Date.parse(self.commission_rule.month).beginning_of_month
    month_end = Date.parse(self.commission_rule.month).end_of_month
    # self.commission_rule.commission_rule_inputs.each do |inpt|
    #   puts "ononononon kjsdjksd ----- dsjkdskj--------skskjsd ------kjsdjksd "
    #   product_id = inpt.product_id
    #   user_sales = UserSale.by_recorded_at_between(month_begn.to_s,month_end.to_s).by_resource_id(resource_id).by_product_id(product_id)
    #   user_sales.each do |user_sale|
    #     puts "----- ---- kjsdjksd ----- dsjkdskj--------skskjsd ------kjsdjksd "
    #     owner_amount = inpt.commission_rule_output.owner_commission_amount
    #     csm_amount = inpt.commission_rule_output.csm_commission_amount
    #     user_sale.update_column(:owner_commission, owner_amount)
    #     user_sale.update_column(:thirdparty_commission, csm_amount)
    #   end
    # end

    product_id = self.commission_rule_input.product_id
    user_sales = UserSale.by_recorded_at_between(month_begn.to_s,month_end.to_s).by_resource_id(resource_id).by_product_id(product_id)
    user_sales.each do |user_sale|
      owner_amount = self.owner_commission_amount * user_sale.quantity
      csm_amount = self.csm_commission_amount * user_sale.quantity
      user_sale.update_column(:owner_commission, owner_amount)
      user_sale.update_column(:thirdparty_commission, csm_amount)
    end
  end
end
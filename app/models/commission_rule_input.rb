class CommissionRuleInput < ActiveRecord::Base
  attr_accessible :commission_rule_id, :product_id, :commission_rule_output_attributes

  # Model Relations
  belongs_to :product
  belongs_to :commission_rule
  has_one :commission_rule_output, :dependent => :destroy

  accepts_nested_attributes_for :commission_rule_output, allow_destroy: true

  # Model Scopes
  scope :by_product, lambda { |product_id| where(["product_id = ?",product_id]) }
  scope :by_product_in, lambda {|product_ids|where(["product_id IN(?)", product_ids])}

end
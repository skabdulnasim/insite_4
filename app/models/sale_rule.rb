class SaleRule < ActiveRecord::Base
  attr_accessible :name, :status, :sale_rule_type, :valid_from, :valid_till, :specific_type, :sale_rule_input_attributes, :sale_rule_output_attributes

  #Model Association
  has_one :sale_rule_input
  has_one :sale_rule_output
  has_many :lot_sale_rules
  has_many :lots, :through => :lot_sale_rules

  has_many :menu_product_sale_rules
  has_many :menu_products, :through => :menu_product_sale_rules

  has_many :menu_category_sale_rules
  has_many :menu_categories, :through => :menu_category_sale_rules

  accepts_nested_attributes_for :sale_rule_input
  accepts_nested_attributes_for :sale_rule_output

  TYPE = %w(generic specific bill_buster)
  STATUS = %w(active inactive)
  SPECIFICTYPE = %w(by_amount by_product by_lot)

  #Model scope
  scope :active, lambda { where(["status = ?",'active']) }
  scope :generic, lambda { where(["sale_rule_type = ?",'generic']) }
  scope :specific, lambda { where(["sale_rule_type = ?",'specific']) }
  scope :bill_buster, lambda { where(["sale_rule_type = ?", 'bill_buster']) }
  scope :set_sale_rule_type_in, lambda {|sale_rule_types|where(["sale_rule_type in (?)", sale_rule_types])}
  scope :by_specific_type, lambda {|specific_type|where(["specific_type = ?", specific_type])}
  scope :valid_till,  lambda { where(["valid_till >=?", Date.today]) }
end

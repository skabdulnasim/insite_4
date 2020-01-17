class TaxClass < ActiveRecord::Base
  paginates_per 10
  attr_accessible :name, :rest_reg_no, :tax_type, :ammount, :amount_type, :upper_limit, :lower_limit, :operation_type
  has_and_belongs_to_many :tax_groups
  has_and_belongs_to_many :sections

  # => Defining Bill statuses
  AMOUNT_TYPES = %w(percentage fixed_amount)
  TAX_LIMIT = %w(Upper Lower)
  OPERTAION_TYPE = %w(igst)
  # => Dynamic methods for types
  AMOUNT_TYPES.each do |amount_type|
    define_method "#{amount_type}?" do
      self.amount_type == amount_type
    end
  end

  # => Dynamically defining these custom finder methods
  class << self
    AMOUNT_TYPES.each do |amount_type|
      define_method "#{amount_type}" do
        where(["amount_type=?", amount_type])
      end
    end
  end

  scope :get_tax_ammount, lambda {|tax_id| where(["id = ?", tax_id])}
  scope :by_ammount, lambda {|ammount|where(["ammount=?",ammount])}
  scope :by_tax_type, lambda{|tax_type| where(["tax_type=?",tax_type])}
  scope :by_tax_classes, lambda{|tax_class_ids| where(["id IN (?)",tax_class_ids])}
end

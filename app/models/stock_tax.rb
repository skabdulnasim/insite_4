class StockTax < ActiveRecord::Base
  attr_accessible :stock_id, :tax_amount, :tax_class_id, :tax_class_name, :tax_percentage, :tax_type, :tax_applicable_on
  TAX_TYPES = %w(input_tax)
  
  belongs_to :stock
  belongs_to :tax_class

  # => Model Validations
  validates :stock_id,       :presence => true
  validates :tax_class_id,   :presence => true
  validates :tax_amount,     :presence => true
  validates :tax_percentage, :presence => true
  validates :tax_type,       :presence => true, :inclusion => {:in => TAX_TYPES}

  # => Dynamic methods for bill statuses
  TAX_TYPES.each do |type|
    define_method "#{type}?" do
      self.tax_type == type
    end
  end

  # => Dynamically defining these custom finder methods
  class << self
    TAX_TYPES.each do |type|
      define_method "#{type}" do
        where(["tax_type=?", type])
      end
    end
  end 

  def self.add_stock_tax stock_id, tax_class_id, tax_amount, tax_applicable_on
    _tax_class = TaxClass.find(tax_class_id)
    _stock_tax = StockTax.create(:stock_id=>stock_id,:tax_class_id=> _tax_class.id, :tax_class_name=> _tax_class.name, :tax_percentage=> _tax_class.ammount, :tax_type=> "input_tax", :tax_amount=> tax_amount, :tax_applicable_on=>tax_applicable_on)
  end 
end

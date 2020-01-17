class ProductComposition < ActiveRecord::Base
  attr_accessible :basic_unit, :inventory_quantity, :product_id, :raw_product_id, :raw_product_quantity, :raw_product_unit, :raw_product_name
  
  # => Defining Relations
  belongs_to :product
  belongs_to :product_unit, :class_name => "ProductUnit", :foreign_key => "raw_product_unit"
  belongs_to :raw_product, :class_name => "Product", :foreign_key => "raw_product_id"
  
  before_validation :set_attributes

  # => Defining Validations
  validates :raw_product_id,      :presence => true
  validates :raw_product_quantity,:presence => true
  validates :raw_product_unit,    :presence => true  
  validates :inventory_quantity,  :presence => true  
  validates :basic_unit,          :presence => true  
  
  delegate  :name, :basic_unit,
            :to => :product,
            :prefix => true
            
  # => Model scopes
  scope :set_product,     lambda {|product_id|where(["product_id=?", product_id])}
  scope :set_raw_product, lambda {|raw_product_id|where(["raw_product_id=?", raw_product_id])}
  def raw_product_name=(name)

  end
  def raw_product_name
    self.raw_product.name
  end

  private

  def set_attributes
    self.inventory_quantity = (self.product_unit.multiplier.to_f)*(self.raw_product_quantity.to_f)
    self.basic_unit = self.raw_product.basic_unit
  end

  def self.get_sub_products(mp_id)
    _product_raw = self.where(:product_id => mp_id)
    _product_raw.each do |pr|
      puts pr.inspect
    end
    return _product_raw
  end

  def self.get_product_details_by_id(id)
    _product_details=Product.find(id)
    return _product_details
  end

  def self.get_product_unit_details(id)
    _product_unit_details = ProductUnit.find(id)
    return _product_unit_details
  end
end

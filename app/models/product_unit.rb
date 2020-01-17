class ProductUnit < ActiveRecord::Base
  paginates_per 10
  attr_accessible :name, :short_name, :basic_inventory_unit, :multiplier, :product_basic_unit_id
  belongs_to :product_basic_unit
  validates :name, :short_name, :basic_inventory_unit, :multiplier, :presence => true
  
  before_validation :set_attributes

  scope :get_product_unit_name, lambda {|id|where(["id=?", id])}
  scope :by_basic_unit, lambda {|id|where(["product_basic_unit_id=?", id])}

  private

  def set_attributes
    _basic_unit = ProductBasicUnit.find(self.product_basic_unit_id)
    self.basic_inventory_unit = _basic_unit.short_name
  end
  
end

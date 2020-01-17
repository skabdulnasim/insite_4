class ProductAttributeValue < ActiveRecord::Base  
  attr_accessible :code, :label, :value, :product_attribute_key_id

  # Relations  
  belongs_to :product
  belongs_to :product_attribute_key

  # Validations
  before_validation :set_attributes
  before_save :check_by_value

  #Scopes
  scope :by_code,   lambda {|code|where(["code=?", code])}

  def self.attribute_by_code code
    _attr = self.by_code(code).first
    return _attr.present? ? _attr.value : ""
  end

  private

  def set_attributes
    self.code = self.product_attribute_key.attribute_code
    self.label = self.product_attribute_key.label
  end

  def check_by_value
    product_attribute_values = ProductAttributeValue.where("product_id =? AND product_attribute_key_id =?", self.product_id, self.product_attribute_key_id)
    product_attribute_values.destroy_all if product_attribute_values.present?
  end
end

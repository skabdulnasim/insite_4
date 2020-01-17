class ColorProduct < ActiveRecord::Base
  attr_accessible :color_id, :product_id, :color_name, :status

  belongs_to :product
  belongs_to :color

  before_validation :set_attributes

  #Model scope
  scope :by_product_id,  lambda {|product_id|where(["product_id=?", product_id])}
  scope :enabled, lambda{where(["status=?",0])}

  private

  def set_attributes
    self.color_name = self.color.name
  end
end

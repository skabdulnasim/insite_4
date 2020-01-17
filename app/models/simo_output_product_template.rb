class SimoOutputProductTemplate < ActiveRecord::Base
  attr_accessible :input_product_id, :product_id
  belongs_to :product

  scope :input_product, lambda {|input_product_id|where(["input_product_id=?", input_product_id])}
  def self.save_template(input_product_id, product_id)
  	template = SimoOutputProductTemplate.new
  	template[:input_product_id] = input_product_id
  	template[:product_id] = product_id
  	template.save
  end
  
end

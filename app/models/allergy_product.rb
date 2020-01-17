class AllergyProduct < ActiveRecord::Base
  attr_accessible :allergy_id, :product_id
  belongs_to :product
  belongs_to :allergy
  scope :by_product,   lambda {|product_id|where(["product_id=?",product_id])}
  def self.save_product_to_allergy_product(product,allergy_ids)
    prev = self.where('product_id =?', product)
    prev.destroy_all if prev.present?
    allergy_ids.each do |allergy_id|
     	allergy_product = AllergyProduct.new
      allergy_product[:product_id] = product
      allergy_product[:allergy_id] = allergy_id
      allergy_product.save
    end
  end
end

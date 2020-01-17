class StoreProduct < ActiveRecord::Base
  belongs_to :product
  belongs_to :store	
  attr_accessible :product_id, :store_id, :store_products_attributes
  validates :product_id, :presence => true
  validates :store_id,  :presence => true

  #Model Scope
  scope :by_product,   lambda {|product_id| where(["product_id = ?", product_id])}
  scope :set_store_in, lambda {|store_ids|where(["store_id in (?)", store_ids])}

  def self.save_product_to_store(product,store_ids)
    store_ids.each do |store_id|
     	store_product = StoreProduct.new
      store_product[:product_id] = product.id
      store_product[:store_id] = store_id
      store_product.save
    end
  end
end

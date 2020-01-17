class PurchaseOrderMetum < ActiveRecord::Base
  attr_accessible :product_amount, :product_id, :purchase_order_id, :secondary_amount, :secondary_product_unit_id, :vendor_price, :color_id, :size_id, :price_per_unit, :status, :purchase_order_metum_descrptions_attributes
  belongs_to :purchase_order
  belongs_to :product
  belongs_to :color
  belongs_to :size
  belongs_to :product_unit, :class_name => "ProductUnit", :foreign_key => :secondary_product_unit_id
  belongs_to :product_transaction_unit, :class_name => "ProductTransactionUnit", :foreign_key => :transaction_unit_id
  has_many :purchase_order_metum_descrptions, :dependent => :destroy

  accepts_nested_attributes_for :purchase_order_metum_descrptions

  scope :by_product, lambda {|product|where(["product_id=?", product])}
  scope :by_color,   lambda {|color_id|where(["color_id=?", color_id])}
  scope :by_size,    lambda {|size_id|where(["size_id=?", size_id])}
  scope :cancelled,  lambda {where(["status = ?", 'cancelled'])}
  scope :not_cancelled,  lambda {where(["status is NULL or status != 'cancelled'"])}

  def vendor_price
   	@vendor_price
  end
  
  def vendor_price=(price)
  	@vendor_price = price
  end

  after_create :update_vendor_price

  private

  def update_vendor_price
  	if @vendor_price.present?
	  	product_id = self.product_id
	  	vendor_id = self.purchase_order.vendor_id
	  	vendor_product = VendorProduct.by_vendor_product(product_id,vendor_id).first
	  	vendor_product.update_attributes(:price=>@vendor_price)
	  end
	end  
end

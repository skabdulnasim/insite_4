class PurchaseOrderMetumDescrption < ActiveRecord::Base
  attr_accessible :color_id, :product_id, :purchase_order_id, :purchase_order_metum_id, :quantity, :size_id
  belongs_to :purchase_order_metum
  before_create :set_attributes
  belongs_to :color
  belongs_to :size

  scope :set_purchase_order_metum_descriptions, lambda{|purchase_order_id,purchase_order_metum_id,product_id,color_id,size_id| where (["purchase_order_id = ? and purchase_order_metum_id = ? and product_id = ? and color_id = ? and size_id = ?", purchase_order_id,purchase_order_metum_id,product_id,color_id,size_id])}
  scope :set_purchase_order_metum_color, lambda{|purchase_order_id,purchase_order_metum_id,product_id,color_id| where (["purchase_order_id = ? and purchase_order_metum_id = ? and product_id = ? and color_id = ?", purchase_order_id,purchase_order_metum_id,product_id,color_id])}
  scope :set_purchase_order_metum_size, lambda{|purchase_order_id,purchase_order_metum_id,product_id,size_id| where (["purchase_order_id = ? and purchase_order_metum_id = ? and product_id = ? and size_id = ?", purchase_order_id,purchase_order_metum_id,product_id,size_id])}

  private

  def set_attributes
  	self.purchase_order_id = self.purchase_order_metum.purchase_order_id
  end
end
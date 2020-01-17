class BillSplitProduct < ActiveRecord::Base
  attr_accessible :bill_split_id, :price, :product_id, :quantity, :order_detail_id, :subtotal, :tax_amount, :unit_price_with_tax

  # => Model relations
  belongs_to :bill_split
  belongs_to :order_detail
  belongs_to :product

  # => Model validations
  #validates :bill_split_id, :presence => true
  #validates :price,         :presence => true
  #validates :product_id,    :presence => true
  #validates :quantity,      :presence => true

  def initialize(attributes=nil, *args)
    super
    if new_record?               
      self.product_id = self.order_detail.product_id
      self.price 	  = self.order_detail.product_price
      self.unit_price_with_tax   = self.order_detail.unit_price_with_tax
      self.subtotal   = self.unit_price_with_tax * self.quantity
      self.tax_amount = self.order_detail.tax_amount
    end
  end

end

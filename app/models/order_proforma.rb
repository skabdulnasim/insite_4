class OrderProforma < ActiveRecord::Base
	attr_accessible :order_id, :proforma_id

	# Model Relations
  belongs_to :order
  belongs_to :proforma

  after_save :update_order_as_proforma
  # accepts_nested_attributes_for :order

  def update_order_as_proforma
  	_order = Order.find(self.order_id)
  	_order.update_attribute(:has_proforma, 1)
  end
end
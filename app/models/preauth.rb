class Preauth < ActiveRecord::Base
  attr_accessible :amount, :customer_queue_id, :device_id, :unit_id, :customer_id, :advance_id, :advance_type, :pre_payments_attributes
  #Model association
  has_many :pre_payments
  belongs_to :customer_queue
  belongs_to :advance, polymorphic: true
  belongs_to :order
  #Model calback
  after_create :update_customer_queue
  after_create :update_order
  #Model validation
  validates :customer_queue_id, :presence => true

  accepts_nested_attributes_for :pre_payments, allow_destroy: true
  private

  	def update_customer_queue
  		_status = true
  		self.customer_queue.update_attributes(:customer_queue_state_id => 2,:is_preauth => _status,:transaction_id =>pre_payments.first.transaction_id ) if self.advance_type == "CustomerQueue"
  	end

    def update_order
      if self.advance_type == "Order"
        order = Order.find(self.advance_id)
        order.update_attributes(:advance_payment => self.amount)
      end
    end
end
class PrePayment < ActiveRecord::Base
  attr_accessible :pre_paymentmode_id, :pre_paymentmode_type, :preauth_id, :pre_paymentmode_attributes

  belongs_to :preauth
  belongs_to :pre_paymentmode, polymorphic: true

  accepts_nested_attributes_for :pre_paymentmode, allow_destroy: true

  validates :pre_paymentmode_type, presence: true

  delegate :amount,:transaction_id, to: :pre_paymentmode

  def attributes=(attributes = {})
    self.pre_paymentmode_type = attributes[:pre_paymentmode_type]
    super
  end

  def pre_paymentmode_attributes=(attributes)
    pre_payment = self.pre_paymentmode_type.camelize.classify.constantize.new
    pre_payment.attributes = attributes
    self.pre_paymentmode = pre_payment
  end  
end
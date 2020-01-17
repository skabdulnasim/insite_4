class ThirdPartyPayment < ActiveRecord::Base
  attr_accessible :amount, :third_party_payment_option_name, :third_party_payment_option_id

  # => Model relations
  has_one :payment, as: :paymentmode

  # => Model validations
  validates :third_party_payment_option_id, presence: true  
  validates :amount, presence: true 

  before_validation :set_extra_attributes

  private

  def set_extra_attributes
    _tpo = ThirdPartyPaymentOption.find(self.third_party_payment_option_id)
    self.third_party_payment_option_name = _tpo.name
  end 
end

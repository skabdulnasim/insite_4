class CouponPayment < ActiveRecord::Base
  attr_accessible :amount, :denomination, :name, :no, :provider, :validity, :coupon_id

  has_one :payment, as: :paymentmode
  belongs_to :coupon

  # Validations 
  validates :coupon_id, presence: true
  validates :amount, presence: true
  before_validation :set_extra_attributes

  private

  def set_extra_attributes
    _coupon = Coupon.find(self.coupon_id)
    self.name = _coupon.name
  end 
end

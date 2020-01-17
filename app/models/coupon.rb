class Coupon < ActiveRecord::Base
  attr_accessible :name, :code, :coupon_type, :amount_type, :amount, :status, :count, :valid_from, :valid_to
 
  STATUS = %w(active inactive)
  COUPON_TYPE = %w(inside outside)
  AMOUNT_TYPE = %w(by_percentage by_amount)

  # Validations 
  validates :name, :coupon_type, :amount_type, :amount, :status, :count, :valid_from, :valid_to, presence: true
  validates :code, uniqueness: true

  scope :by_code, lambda { |code| where(["code = ?", code]) }

  def self.check_coupon_date_validity(current_date)
    where('? BETWEEN coupons.valid_from AND coupons.valid_to',current_date)
  end
end

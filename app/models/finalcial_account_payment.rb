class FinalcialAccountPayment < ActiveRecord::Base
  attr_accessible :account_no, :amount, :customer_id, :finalcial_account_id
  has_one :payment, as: :paymentmode

  #validations
  validates :amount, presence: true
  validates :finalcial_account_id, presence: :true
end

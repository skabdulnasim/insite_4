class PrePaypalPayment < ActiveRecord::Base
  attr_accessible :amount, :transaction_id, :recorded_at
  has_one :pre_payment, as: :pre_paymentmode
  validates :amount, presence: true  
  validates :transaction_id, presence: true 
end

class PaypalPayment < ActiveRecord::Base
  attr_accessible :amount, :recorded_at, :transaction_id
  validates :amount, presence: true  
  validates :transaction_id, presence: true 
end

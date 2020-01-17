class AccountPayment < ActiveRecord::Base
  attr_accessible :amount, :user_id, :user_name

  # => Model relations
  has_one :payment, as: :paymentmode

  # => Model validations
  validates :user_id, presence: true  
  validates :amount, presence: true 
end

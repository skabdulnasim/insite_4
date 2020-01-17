class WalletPayment < ActiveRecord::Base
  attr_accessible :amount, :card_number, :customer_phone, :wallet_name
  has_one :payment, as: :paymentmode

  #validations
  validates :amount, presence: true
end

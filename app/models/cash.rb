class Cash < ActiveRecord::Base
	#include DateLimit
  attr_accessible :balance_return, :denomination, :tendered_amount, :amount, :cash_descriptions_attributes, :transaction_currency_details_attributes
  has_one :payment, as: :paymentmode
  has_many :cash_descriptions
  has_many :transaction_currency_details
  accepts_nested_attributes_for :cash_descriptions
  accepts_nested_attributes_for :transaction_currency_details

  
  # Validations 
  validates :amount, presence: true  
  
end

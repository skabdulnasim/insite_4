class Card < ActiveRecord::Base
  TYPE = "card"
  attr_accessible :amount, :bank, :cvv, :merchandiser, :name_on_card, :no, :card_type, :valid_upto
  has_one :payment, as: :paymentmode
  
  # Validations 
  validates :amount, presence: true
end
class FatCard < ActiveRecord::Base
  attr_accessible :amount, :bank, :card_no, :card_type, :cvv, :merchandiser, :name_on_card, :valid_upto

  # Model Relations
  has_one :financial_account_transaction, as: :fat_paymentmode
end
class FatCash < ActiveRecord::Base
  attr_accessible :amount

  # Model Relations
  has_one :financial_account_transaction, as: :fat_paymentmode
end
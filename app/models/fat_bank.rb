class FatBank < ActiveRecord::Base
  attr_accessible :amount, :bank_name, :identity, :mode

  # Model Relations
  has_one :financial_account_transaction, as: :fat_paymentmode
end
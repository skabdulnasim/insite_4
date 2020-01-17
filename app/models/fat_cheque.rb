class FatCheque < ActiveRecord::Base
  attr_accessible :amount, :bank_name, :cheque_no, :clearnce_date

  # Model Relations
  has_one :financial_account_transaction, as: :fat_paymentmode  
end
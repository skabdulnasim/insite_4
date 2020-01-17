class WalletBankCreditMode < ActiveRecord::Base
  attr_accessible :amount, :bank_namy, :identity, :mode
  has_one :wallet_transaction, as: :creditmode
end

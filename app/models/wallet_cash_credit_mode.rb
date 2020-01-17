class WalletCashCreditMode < ActiveRecord::Base
  attr_accessible :amount, :remarks
  has_one :wallet_transaction, as: :creditmode
end

class CustomerWalletPayment < ActiveRecord::Base
  attr_accessible :amount, :customer_id, :wallet_id, :mobile_no
  has_one :payment, as: :paymentmode
  belongs_to :wallet
  #validations
  validates :amount, presence: true
  validates :wallet_id, presence: :true
  #Model callback
  after_create :debit_wallet_transaction

  def debit_wallet_transaction
  	self.wallet.debit(self.amount,"Bill settlement","Wallet debit transaction")
  	self.update_attributes(:customer_id => self.wallet.customer_id, :mobile_no => self.wallet.customer.mobile_no)
  end
end

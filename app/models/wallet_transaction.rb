class WalletTransaction < ActiveRecord::Base
  belongs_to :wallet
  attr_accessible :amount, :payment_type, :purpose, :remarks, :identity, :creditmode_type, :creditmode_attributes,:quotation_id
  has_one :payment, as: :paymentmode
  belongs_to :creditmode, polymorphic: true
  accepts_nested_attributes_for :creditmode, allow_destroy: true

  def attributes=(attributes = {})
    self.creditmode_type = attributes[:credittmode_type]
    super
  end

  def creditmode_attributes=(attributes)
    creditmode = self.creditmode_type.camelize.classify.constantize.new
    creditmode.attributes = attributes
    self.creditmode = creditmode
  end 

  #validates :creditmode_type, presence: true
  def identity
    Wallet.find(wallet_id) if wallet_id.present?
  end

  def identity=(identity)
    self.wallet_id = Wallet.search(identity).first.id if Wallet.search(identity).first.present?
  end

  after_create :deduct_wallet_amount

  def deduct_wallet_amount
    # self.wallet.deduct(self.amount) if self.payment_type == 'debit'
  end
end

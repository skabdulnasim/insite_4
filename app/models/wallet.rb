class Wallet < ActiveRecord::Base
  belongs_to :customer
  attr_accessible :current_balance, :total_credit, :total_debit, :customer_id
  has_many :wallet_transactions

  scope :search, ->(identity){ joins(:customer).merge(Customer.by_identification(identity)).readonly(false) }
  #PAYMENTS_TYPES = %w(credit debit)
  
  # PAYMENT_TYPES.each do |type|
  #   define_method "#{type}?" do
  #     self.question_type == type
  #   end
  # end

  def credit (attributes)
    #wallet_transactions.build({amount: amount,purpose: purpose, remarks: remarks, payment_type: 'credit'})
    obj = wallet_transactions.build(attributes)
    self.current_balance = self.current_balance + obj.first.amount
    self.total_credit = self.total_credit + obj.first.amount
    self.save
  end

  def debit(amount,purpose,remarks)
    wallet_transactions.build({amount: amount,purpose: purpose, remarks: remarks, payment_type: 'debit'})
    self.current_balance = self.current_balance - amount
    self.total_debit = self.total_debit + amount
    self.save
  end

  def deduct(amount)
    self.current_balance = self.current_balance - amount
    self.total_debit = self.total_debit + amount
    self.save
  end
  
  # def initialize(attributes=nil, *args)
  #    super
  #    credit({amount: 0,purpose:'Account Open',remarks:''}) if new_record?
  # end
end

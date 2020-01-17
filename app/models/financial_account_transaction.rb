class FinancialAccountTransaction < ActiveRecord::Base
  attr_accessible :amount, :purpose, :remarks, :transaction_type, :consumer_id, :transaction_entity_type, :transaction_entity_id, :fat_paymentmode_type, :fat_paymentmode_id, :device_id, :consumer_type, :financial_account_id, :debited_acc_id, :recorded_at, :fat_paymentmode_attributes

  # Model Relations
  belongs_to :fat_paymentmode, polymorphic: true
  belongs_to :transaction_entity, polymorphic: true
  belongs_to :financial_account
  belongs_to :user, :foreign_key => :consumer_id

  accepts_nested_attributes_for :fat_paymentmode, allow_destroy: true

  #Model validation 
  validates :fat_paymentmode_type, presence: true
  #model callback
  #after_create :update_financial_account_for_user_proforma , if:->{self.transaction_entity_type=="Proforma" && self.consumer_type=="user"}
  after_create :update_financial_account
  #active record scope
  scope :transaction_type, lambda{|transaction_type|where(["transaction_type = ?",transaction_type])}

  def initialize(attributes=nil, *args)
    super
    if new_record?
      initialized = (attributes || {}).stringify_keys
      if !initialized.key?('recorded_at')
        self.recorded_at = Time.now.utc
      else 
        self.recorded_at = self.recorded_at.utc
      end
    end
  end

  def attributes=(attributes = {})
    self.fat_paymentmode_type = attributes[:fat_paymentmode_type]
    super
  end

  def fat_paymentmode_attributes=(attributes)
    payment = self.fat_paymentmode_type.camelize.classify.constantize.new
    payment.attributes = attributes
    self.fat_paymentmode = payment
  end

  def update_financial_account
    financial_account = FinancialAccount.find(self.financial_account_id)
    if financial_account.present?
      if self.transaction_type == "credit"
        financial_account.update_attribute(:total_credit,financial_account.total_credit.to_i+self.amount) 
      else
        financial_account.update_attribute(:total_debit,financial_account.total_debit.to_i+self.amount)
      end
      financial_account.update_attribute(:current_balance,financial_account.total_credit.to_i-financial_account.total_debit.to_i)
    else
      @validation_errors = error_messages_for(financial_account)
    end
  end
end

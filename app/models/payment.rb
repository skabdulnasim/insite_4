class Payment < ActiveRecord::Base
  #include DateLimit
  attr_accessible :paymentmode_type, :settlement_id, :paymentmode_id, :bill_split_id, :split_settlement_id,
                  :paymentmode_attributes
  belongs_to :settlement
  belongs_to :split_settlement  
  belongs_to :paymentmode, polymorphic: true
  has_one     :cash_in
  
  accepts_nested_attributes_for :paymentmode, allow_destroy: true
  
  # Validations 
  validates :paymentmode_type, presence: true

  delegate :amount, to: :paymentmode
  delegate :finalcial_account_id, to: :paymentmode
  after_save :update_payment
  after_create :save_amount_cash_in
  after_create :debit_from_finalcial_account, if:->{self.paymentmode_type=="FinalcialAccountPayment"}

  def attributes=(attributes = {})
    self.paymentmode_type = attributes[:paymentmode_type]
    super
  end

  def paymentmode_attributes=(attributes)
    payment = self.paymentmode_type.camelize.classify.constantize.new
    payment.attributes = attributes
    self.paymentmode = payment
  end 

  def save_amount_cash_in
    if self.split_settlement.present?
      #CashIn.save_into_cash_in(self.split_settlement.bill.unit_id,self.split_settlement.bill.biller_id,self.paymentmode.amount,"Bill settlement by cash",self.settlement.bill.device_id,self.settlement.recorded_at,self.settlement.bill.serial_no,self.paymentmode_id) if self.paymentmode_type == "Cash"
    else
      CashIn.save_into_cash_in(self.settlement.bill.unit_id,self.settlement.bill.biller_id,self.paymentmode.amount,"Bill settlement by cash",self.settlement.bill.device_id,self.settlement.recorded_at,self.settlement.bill.serial_no,self.paymentmode_id) if self.paymentmode_type == "Cash"
    end 
  end 

  private

  def update_payment
    if self.split_settlement.present?
      self.update_column(:settlement_id, self.split_settlement.settlement_id)
    end  
  end

  def debit_from_finalcial_account
    financial_account_debit_transaction = FinancialAccountTransaction.new(financial_transaction_debit_params())
    if financial_account_debit_transaction.save
      financial_account_debit_transaction = financial_account_debit_transaction.reload
      financial_account_id = self.settlement.bill.unit.financial_account.id if self.settlement.bill.unit.financial_account.present?
      if financial_account_id.present?
        credit_to_transaction(financial_transaction_outlet_credit_params(financial_account_id,financial_account_debit_transaction.financial_account_id))
      else
         @validation_errors = error_messages_for(financial_account)
      end
    else
      @validation_errors = error_messages_for(financial_account_debit_transaction)
    end
  end

  def credit_to_transaction(financial_accounts_transaction_param)
    @financial_account_transaction = FinancialAccountTransaction.new(financial_accounts_transaction_param)
    if @financial_account_transaction.save
      @financial_account_transaction.reload
    else  
      @validation_errors = error_messages_for(@financial_account_transaction)
    end
  end

  def financial_transaction_debit_params()
    {
    "amount"                  => self.amount,
    "device_id"               => self.settlement.device_id,
    "purpose"                 => "Invoice post to account",
    "remarks"                 => "Settled invoice",
    "transaction_type"        => "debit", 
    "consumer_id"             => self.settlement.client_id,
    "consumer_type"           => 'User',
    "financial_account_id"    => self.finalcial_account_id,
    "transaction_entity_id"   => self.settlement.bill_id,
    "transaction_entity_type" => "Bill",
    "fat_paymentmode_type"    => "FatInternal" #this field might need to be changed
    }
  end

  def financial_transaction_outlet_credit_params(financial_account_id,debited_acc_id)
    {
    "amount"                  => self.amount,
    "device_id"               => self.settlement.device_id,
    "purpose"                 => "Invoice post to account",
    "remarks"                 => "Settled invoice",
    "transaction_type"        => "credit", 
    "consumer_id"             => self.settlement.client_id,
    "consumer_type"           => 'User',
    "transaction_entity_type" => "Bill",
    "transaction_entity_id"   => self.settlement.bill_id,
    "financial_account_id"    => financial_account_id,
    "debited_acc_id"          => debited_acc_id,
    "fat_paymentmode_type"    => "FatInternal" #this field might need to be changed
    }
  end
end

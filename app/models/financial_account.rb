class FinancialAccount < ActiveRecord::Base
  
  attr_accessible :account_holder_id, :account_holder_type, :current_balance, :total_credit, :total_debit, :acc_no, :account_type

  # Model Relations
  belongs_to :account_holder, polymorphic: true
  has_many :financial_account_transactions

  # Model Relations
  scope :set_account_holder_type,    lambda {|ah_type|where(["account_holder_type=?", ah_type])}
  scope :set_account_holder,         lambda {|ah_id|where(["account_holder_id=?", ah_id])}

  # Model Callbacks
  after_create :update_acc_no

  def initialize(attributes=nil, *args)
  	super
  	if new_record?
  		initialized = (attributes || {}).stringify_keys
      if !initialized.key?('current_balance')
        self.current_balance = 0
      end
      if !initialized.key?('total_credit')
        self.total_credit = 0
      end
      if !initialized.key?('total_debit')
        self.total_debit = 0
      end
		end
  end

  # def credit (attributes)
  # 	#financial_account_transactions.build({amount: amount,purpose: purpose, remarks: remarks, transaction_type: 'credit'})
  #   obj = financial_account_transactions.build(attributes)
  #   self.current_balance = self.current_balance + obj.first.amount
  #   self.total_credit = self.total_credit + obj.first.amount
  #   self.save
  # end

  # def debit(attributes)
  #   # wallet_transactions.build({amount: amount,purpose: purpose, remarks: remarks, transaction_type: 'debit'})
  #   obj = financial_account_transactions.build(attributes)
  #   self.current_balance = self.current_balance - obj.first.amount
  #   self.total_debit = self.total_debit + obj.first.amount
  #   self.save
  # end

  # Data export to CSV
  def self.account_transactions_history_to_csv(unit_id,account_holder_type,customer_id)
    if account_holder_type == "Unit"
      @account_holder = Unit.find(unit_id)
    elsif account_holder_type == "Customer"
      @account_holder = Customer.find(customer_id)
    end
    CSV.generate do |csv|
      _headers = ["Amount","Transaction Type","Payment Mode","Receiver","Device","Date","Purpose","Remarks"]
      csv<<_headers
      if @account_holder.financial_account.present?
        @account_transactions = @account_holder.financial_account.financial_account_transactions.order("id desc").limit(100)
        if @account_transactions.present?
          @account_transactions.each do |ledger|
            _transaction_details = Array.new
            _transaction_details.push ledger.amount
            _transaction_details.push ledger.transaction_type
            _transaction_details.push ledger.fat_paymentmode_type.split('Fat')[1]
            _transaction_details.push ledger.user.profile.full_name
            _transaction_details.push ledger.device_id
            if ledger.recorded_at.present?
              _transaction_details.push ledger.recorded_at.strftime("%d-%m-%Y, %I:%M %p")
            else
              _transaction_details.push ledger.created_at.strftime("%d-%m-%Y, %I:%M %p") 
            end  
            _transaction_details.push ledger.purpose
            _transaction_details.push ledger.remarks
            csv<<_transaction_details
          end
        end
      end
    end
  end


  private

  def update_acc_no
    acc_no = "10101010#{self.account_holder_id}#{self.id}"
    self.update_column(:acc_no, acc_no)
  end

end
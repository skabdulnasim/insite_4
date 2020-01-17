class Pay < ActiveRecord::Base
  attr_accessible :credit_amount, :debit_amount, :pay_transaction_id, :pay_transaction_type, :unit_id, :user_id, :available_amount, :device_id
  belongs_to :pay_transaction, polymorphic: true
  has_one :stock_update
  belongs_to :unit
  belongs_to :user
  after_create :update_pay_counter

  TRANSACTION_TYPE = %w(CashIn CashOut)

  TRANSACTION_TYPE.each do |pay_transaction_type|
    define_method "#{pay_transaction_type}?" do
      self.pay_transaction_type == pay_transaction_type
    end
  end

  #Model scope
  scope :set_transaction_type_in, lambda {|pay_transaction_types|where(["pay_transaction_type in (?)", pay_transaction_types])}
  scope :set_transaction_type, lambda {|pay_transaction_type|where(["pay_transaction_type=?",pay_transaction_type])}
  scope :by_unit,             lambda {|unit_id|where(["unit_id=?", unit_id])}
  scope :by_date_range,       lambda {|from_date, upto_date|where('created_at BETWEEN ? AND ?',from_date,upto_date)}
  scope :set_id,              lambda {|id|where(["pays.id=?", id])}
  scope :set_credit_amount,   lambda {|credit_amount|where(["pays.credit_amount=?", credit_amount])}
  scope :set_debit_amount,   lambda {|debit_amount|where(["pays.debit_amount=?", debit_amount])}
  scope :by_user,            lambda {|user_id|where(["user_id=?", user_id])}
  scope :by_device_id,        lambda {|device_id|where(["device_id=?", device_id])}

  def self.cash_save(transaction_id,pay_transaction_type,credit_amount,debit_amount,available_amount,user_id,unit_id,device_id)
    _transaction                =   pay_transaction_type.capitalize.classify.constantize.find(transaction_id)
    _new_pay                    =   _transaction.pays.new
    _new_pay[:credit_amount]   =   credit_amount
    _new_pay[:debit_amount]     =   debit_amount
    _new_pay[:available_amount] =   available_amount
    _new_pay[:user_id]          =   user_id
    _new_pay[:unit_id]          =   unit_id
    _new_pay[:device_id]        =   device_id
    _new_pay.save
    return _new_pay
  end

  def self.get_unit_cash_data(unit_id,from_datetime,to_datetime)
    cash_data = {}
    cash_data[:cash_in] = Pay.by_unit(unit_id).by_date_range(from_datetime, to_datetime).set_transaction_type('CashIn').sum(:credit_amount)
    cash_data[:cash_out] = Pay.by_unit(unit_id).by_date_range(from_datetime, to_datetime).set_transaction_type('CashOut').sum(:debit_amount)
    cash_data[:current_cash] = PayUpdate.current_cash(unit_id)
    return cash_data
  end
  
  def self.by_recorded_at(from_date, upto_date)
    where('pays.created_at BETWEEN ? AND ?',from_date,upto_date)
  end

  def self.check_price_range(from_price, to_price)
    if !from_price.empty? && !to_price.empty?
      where('available_amount between ? and ?',from_price,to_price)
    else
      all
    end
  end

  private

  def update_pay_counter
    PayUpdate.update_pay(self.unit_id,self.credit_amount,self.debit_amount,self.id)
  end
  
end

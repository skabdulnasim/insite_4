class Settlement < ActiveRecord::Base
  attr_accessible :bill_amount, :bill_id, :status, :tips, :client_id, :client_type, :split_bill_id, :device_id, :recorded_at,
                  :payments_attributes, :loyalty_credit_transaction_attributes, :split_settlements_attributes
  has_many :payments
  has_one   :loyalty_credit_transaction, as: :loyalty_credit
  belongs_to :bill
  belongs_to :client, polymorphic: true
  has_many :split_settlements
  
  accepts_nested_attributes_for :payments, allow_destroy: true
  accepts_nested_attributes_for :loyalty_credit_transaction
  accepts_nested_attributes_for :split_settlements

  before_validation :set_attributes
  after_save :undate_bill
  after_save :update_table
  after_save :update_settlement
  after_create :update_resource

  # => Defining Bill statuses
  STATUS = %w(unpaid paid)
  CLIENT_TYPE = %w(User Customer)
  
  # => Dynamic methods for statuses
  STATUS.each do |status|
    define_method "#{status}?" do
      self.status == status
    end
  end

  # => Dynamically defining these custom finder methods
  class << self
    STATUS.each do |status|
      define_method "#{status}" do
        where(["status=?", status])
      end
    end
  end

  # Validations 
  validates :bill,        presence: true
  validates :bill_amount, presence: true
  validates :status,      presence: true,
                          :inclusion => {:in => STATUS}
  validates :client,      presence: true
  validates :client_type, :inclusion => {:in => CLIENT_TYPE }
  validate  :validate_settlement
  validates :bill_id, uniqueness: true
  
  def initialize(attributes=nil, *args)
    super
    if new_record?
      # set default values for new records only
      initialized = (attributes || {}).stringify_keys
      if initialized.key?('bill_id') && initialized.key?('split_settlements_attributes')
        self.bill_amount = self.bill.grand_total
        self.status = 'unpaid'
      end
      if initialized.key?('bill_id') && !initialized.key?('split_settlements_attributes')
        self.bill_amount = self.bill.grand_total
        self.status = 'paid'
      end  
      if initialized.key?('client_type')
        self.client_type = self.client_type.camelize
      end
      if !initialized.key?('recorded_at')
        self.recorded_at = Time.now.utc
      else
        self.recorded_at = self.recorded_at.utc
      end                
    end
  end

  # Custom validation for new settlement request.
  def validate_settlement
    if new_record?
      ensure_bill_not_settled_yet
      ensure_receiving_exact_payment unless self.split_settlements.present?
    end
  end

  def ensure_receiving_exact_payment
    errors.add(:base, I18n.t(:error_payment_amount_not_matching, bill_amount: self.bill_amount, payment_amount: payment_received)) unless payment_received == self.bill_amount    
  end

  def ensure_bill_not_settled_yet
    errors.add(:base, I18n.t(:error_bill_already_paid, bill_id: self.bill_id)) if self.bill.paid? 
  end

  def payment_received
    received_amount = bill_roundoff_disabled? ? self.payments.map { |e| e.amount }.sum.round(2) : self.payments.map { |e| e.amount }.sum.round
  end
  
  # Return true if bill roundoff is disabled
  def bill_roundoff_disabled?
    AppConfiguration.get_config_value('apply_bill_roundoff') == 'disabled'
  end
  
  private

  def set_attributes
    # self.client_type = self.client_type.camelize
  end
  def undate_bill
    if self.split_settlements.present?
      self.bill.paid! if self.bill_amount == self.split_settlements.map { |e| e.bill_split_ammount }.sum
      self.bill.boh_amount!
    else
      self.bill.paid!
    end
  end
  
  def update_table
    _order = self.bill.orders.first
    if _order.deliverable_type == "Table"
      if self.split_settlements.present?
        Table.update_table_state(1,_order.unit_id,_order.deliverable_id,self.client_id,self.device_id) if self.bill_amount == self.split_settlements.map { |e| e.bill_split_ammount }.sum
      else
        Table.update_table_state(1,_order.unit_id,_order.deliverable_id,self.client_id,self.device_id)
      end
    end
  end

  def update_settlement
    if self.split_settlements.present?
      self.update_column(:status, 'paid') if self.bill_amount == self.split_settlements.map { |e| e.bill_split_ammount }.sum
    end
  end

  def update_resource
    _order = self.bill.orders.first
    if _order.deliverable_type == "Resource"
      if self.split_settlements.present?
        Resource.update_resource_state(1,_order.unit_id,_order.deliverable_id,self.client_id,self.device_id) if _order.deliverable_type == "Resource"
      else
        Resource.update_resource_state(1,_order.unit_id,_order.deliverable_id,self.client_id,self.device_id)
      end  
    end  
  end

  def self.get_card_wise_report(unit_id,params)
    @unit_detail_options = Unit.where('id=?',unit_id).first.unit_detail.options
    _from_datetime = params[:from_date].to_date.beginning_of_day+@unit_detail_options[:day_closing_time].to_i.hours
    _from_datetime ||= params[:from_date].to_date.beginning_of_day
    _to_datetime = params[:to_date].to_date.end_of_day+@unit_detail_options[:day_closing_time].to_i.hours
    _to_datetime ||= params[:to_date].to_date.end_of_day
    _data = Bill.unit_bills(unit_id).by_recorded_at(_from_datetime,_to_datetime).order("recorded_at asc")
    card_arr = Array.new
    _data.each do |data|
      if data.settlement.present?
        payments = data.settlement.payments
        payments.each do |payment|
          if payment['paymentmode_type'] == "Card"
            card_hash = {}
            card_hash[:bill_id]           = payment.settlement['id']
            card_hash[:card_pay_amount]   = payment.paymentmode['amount']
            card_hash[:bill_amount]       = payment.settlement['bill_amount']
            card_hash[:card_no]           = payment.paymentmode['no']
            card_hash[:card_type]         = payment.paymentmode['card_type']
            card_hash[:created_time]      = payment['created_at'].strftime("%d/%m/%Y %I:%M %p")
            card_arr.push card_hash
          end
        end
      end
    end
    return card_arr
  end

  def self.get_card_wise_report_to_csv(unit_id,sales)
    CSV.generate do |csv|
      _title = ["Bill ID","Card Type","Card No","Card Pay Amount","Bill Amount","Date Time"]
      csv << _title
      sales.each do |sale|
        _row = Array.new
        _row.push(sale[:bill_id])
        _row.push(sale[:card_type])
        _row.push(sale[:card_no])
        _row.push(sale[:card_pay_amount])
        _row.push(sale[:bill_amount])
        _row.push(sale[:created_time])
        csv << _row
      end
    end
  end

end

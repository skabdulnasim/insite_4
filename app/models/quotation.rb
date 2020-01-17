class Quotation < ActiveRecord::Base
  attr_accessible :discount, :grand_total, :quotation_amount, :recorded_at, :remarks, :tax_amount, :roundoff, :serial_no, :status, :unit_id, :device_id, :order_ids, :customer_id
  alias_attribute :advance_payments, :wallet_transactions
  has_many :wallet_transactions
  STATUS = %w(unpaid paid void no_charge cod boh)
  
  belongs_to :unit
  belongs_to :user
  belongs_to :customer
  has_and_belongs_to_many :orders, before_add: :check_unique_order

  def check_unique_order order
    if order.quotations.count >0 
      raise Exception, "Quotation already done for one or all order"
    end
 end
  #accepts_nested_attributes_for :orders, :reject_if => proc { |a| a[:order_id].blank? }
  # => Dynamic methods for bill statuses
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
  scope :by_device,             lambda {|device_id|where(["device_id LIKE ?", device_id])}
  scope :by_unit,               lambda {|unit_id|where(["unit_id=?", unit_id])}
  scope :by_customer,           lambda {|customer_id| where (["customer_id = ?",customer_id])}
  scope :by_customer_identity,  lambda {|customer_identity| joins(:customer).merge(Customer.search(customer_identity))}
  scope :reverse,  -> { order('created_at ASC') }
  scope :by_orders, lambda{|order_ids| joins(:orders).where(orders: { id: order_ids })}
  before_validation :set_attributes

  def initialize(attributes=nil, *args)
    super
    if new_record?
      # set default values for new records only
      initialized = (attributes || {}).stringify_keys
      if !initialized.key?('status')
        self.status = 'unpaid'
      end
      if initialized.key?('deliverable_type')
        self.deliverable_type = self.deliverable_type.camelize
      end
      # if initialized.key?('biller_type')
      #   self.biller_type = self.biller_type.camelize
      # end
      if !initialized.key?('serial_no')
        self.serial_no = generate_serial_number
      end
      # if !initialized.key?('boh_amount')
      #   self.boh_amount = 0
      # end
      if !initialized.key?('recorded_at')
        self.recorded_at = Time.now.utc
      else
        self.recorded_at = self.recorded_at.utc
      end

      # if !initialized.key?('section_id')
      #   self.section_id = self.bill_orders.first.order.section_id
      # end
    end
  end
  
  def order_attributes=(data)
    p data
  end
  
  def set_attributes
    self.quotation_amount = compute_bill_amount
    self.tax_amount  = compute_tax_amount
    #self.discount    = compute_discount
    #self.delivery_charges = compute_delivery_charges
    #self.roundoff    = compute_roundoff
    #self.advance_payment = compute_advance_payment
    self.grand_total = compute_grand_total
  end

  def generate_serial_number
    serial_number = "#{self.unit_id}-#{self.device_id}-1"
    if self.device_id.present?
      _last_quotation = Quotation.by_device(self.device_id).by_unit(self.unit_id).last
      if _last_quotation.present? && _last_quotation.serial_no.present?
        _serial = _last_quotation.serial_no.split("-")
        _serial_no = _serial[2].to_i + 1
        serial_number = "#{self.unit_id}-#{self.device_id}-#{_serial_no}"
      end
    end
    return serial_number
  end

  def compute_bill_amount
    self.orders.map { |e| e.order_total_without_tax }.sum
  end

  def compute_tax_amount
    #self.bill_orders.map { |e| e.order.total_tax }.sum.round(2)
    self.orders.map { |e| e.total_tax }.sum
  end
  
  def compute_grand_total
    self.quotation_amount + self.tax_amount
  end
  # def compute_discount
  #   #discount = self.bill_discounts.map { |e| e.discount_amount }.sum.round(2)
  #   discount = self.bill_discounts.map { |e| e.discount_amount }.sum
  #   discount = bill_amount_with_tax if discount > bill_amount_with_tax
  #   return discount
  # end
end

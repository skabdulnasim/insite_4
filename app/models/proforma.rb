class Proforma < ActiveRecord::Base
  attr_accessible :customer_id, :device_id, :discount, :grand_total, :proforma_amount, :recorded_at, :remarks, :roundoff, :serial_no, :status, :tax_amount, :unit_id, :user_id, :vehicle_id, :billed,
  								:order_proformas_attributes

  # Model Relations
  has_many :order_proformas
  has_many :orders, through: :order_proformas
  belongs_to :customer
  belongs_to :unit
  has_many :financial_account_transactions, as: :transaction_entity

  accepts_nested_attributes_for :order_proformas

  # Model Callbacks
  before_validation :set_attributes
  def initialize(attributes=nil, *args)
    super
    if new_record?
      # set default values for new records only
      initialized = (attributes || {}).stringify_keys
      if !initialized.key?('billed')
        self.billed = 0
      end
    end 
  end   

  # Model Scopes
  scope :set_id, lambda{|proforma_id|where(["id=?", proforma_id])}
  scope :by_unit,               lambda {|unit_id|where(["unit_id=?", unit_id])}
  scope :by_customer,           lambda {|customer_id| where (["customer_id = ?",customer_id])}
  scope :unit_proformas,          lambda {|unit_id|where(["proformas.unit_id=?", unit_id])}
  scope :without_serial,      lambda { where("(device_id = '') IS NOT FALSE")}
  scope :by_billed_status,              lambda {|billed|where(["billed = ?", billed])}
  # def check_unique_order order
  #   if order.proformas.count >0 
  #     raise Exception, "Proforma already done for one or all order"
  #   end
 	# end

 	def set_attributes
    self.proforma_amount = compute_proforma_amount
    self.tax_amount  = compute_tax_amount
    self.grand_total = compute_grand_total
  end

  def compute_proforma_amount
    self.order_proformas.map { |e| e.order.order_total_without_tax }.sum
  end

  def compute_tax_amount
    self.order_proformas.map { |e| e.order.total_tax }.sum
  end
  
  def compute_grand_total
    self.proforma_amount + self.tax_amount
  end

  def self.last_serial_number(unit_id,device_id)
    data_with_no_device = Proforma.unit_proformas(unit_id).without_serial #blank array for no update require
    unless data_with_no_device.empty?
      data_with_no_device.update_all(:device_id=>device_id)
      data = Proforma.where(:unit_id => unit_id,:device_id=>device_id).select("id").order("id")
      data.each_with_index{|item,index| Proforma.update(item.id, serial_no: "#{unit_id}-#{device_id}-#{index+1}")}
    end

    last_serial_no = Proforma.select("MAX(REPLACE(serial_no,'-','')::bigint) AS serial_no").group(:id).where(:unit_id=>unit_id,:device_id=>device_id).first
    last_serial_no.present? ? last_serial_no.serial_no.gsub!("#{unit_id}#{device_id}", ''): 0
  end

end
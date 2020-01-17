class Bill < ActiveRecord::Base
  include ActiveRecordExtension
  attr_accessible :bill_amount, :discount, :grand_total, :status, :deliverable_id, :deliverable_type, :tax_amount,
                  :unit_id, :user_id, :device_id, :serial_no, :pax, :remarks, :roundoff, :biller_type, :biller_id, :recorded_at, :customer_id, :boh_amount, :resource_type, :advance_payment, :delivery_charges, :section_id, :bill_destination_id, :lite_device_id, :is_service_charge, :suffix, :prefix, :bill_discount_percentage,
                  :bill_orders_attributes, :bill_discounts_attributes, :bill_splits_attributes, :proforma_id, :reservation_id

  # => Model relations
  belongs_to  :user
  belongs_to  :unit
  belongs_to  :deliverable, :polymorphic => true
  belongs_to  :biller, :polymorphic => true
  has_many    :bill_orders
  has_many    :bill_splits
  has_many    :orders, through: :bill_orders
  has_many    :bill_tax_amounts, inverse_of: :bill, :dependent => :delete_all
  has_one     :settlement
  has_many    :payments, through: :settlement
  has_many    :bill_discounts, inverse_of: :bill, :dependent => :delete_all
  has_one     :reservation
  has_one     :bill_by_bill_sale
  belongs_to  :customer
  has_many    :bill_reprints
  belongs_to  :section
  belongs_to  :proforma
  has_many :financial_account_transactions, as: :transaction_entity

  accepts_nested_attributes_for :bill_orders, :reject_if => proc { |a| a[:order_id].blank? }
  accepts_nested_attributes_for :bill_discounts, :reject_if => proc { |a| a[:discount_amount].blank? }, allow_destroy: true
  accepts_nested_attributes_for :bill_splits
  # => Model Callbacks
  before_validation :remove_service_charge, 
                    :set_attributes,
                    :apply_nc_void
  after_save  :create_tax_charge!,
              :push_update_to_subscribers,
              :upate_bill
              :change_bill_roundoff_base_on_split_bill
  after_create :update_reservation
  after_create :save_in_bill_by_bill_sale
  after_create :update_proforma_as_billed
  after_create :send_sms,:send_email, if:->{self.status=="cod"}
  # => Defining Bill statuses
  STATUS = %w(unpaid paid void no_charge cod boh cancled)
  BILLER_TYPE = %w(User Customer)


  API_KEY       = 'Q2JRePQw7py'
  MobileNo      = '919933648398'
  SenderID      = 'YOTTOL'
  message       = 'Thank you for your order with Yottolabs, Kolkata. Your Order ID is # "#{self.id}". Please give us 30 min to serve you fresh and hot food.'
  Message       = URI.encode(message)
  ServiceName   = 'TEMPLATE_BASED'
  API_BASE_URL  = "smsapi.24x7sms.com/api_2.0/SendSMS.aspx?APIKEY="

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

  # => Model validations
  validates :status,          :presence => true, :inclusion => {:in => STATUS}
  validates :unit,            :presence => true
  validates :deliverable,     :presence => true
  validates :biller_type,     :inclusion => {:in => BILLER_TYPE }
  validates :biller,          :presence => true
  validates :bill_amount,     :presence => true
  validates :tax_amount,      :presence => true
  validates :discount,        :presence => true
  validates :grand_total,     :presence => true
  validates :serial_no, uniqueness: {message: I18n.t(:error_duplicate_bill)}, :allow_blank => true, :allow_nil => true
  validate  :validate_bill

  # => Model scopes
  scope :set_id,              lambda {|id|where(["bills.id=?", id])}
  scope :where_id_in,         lambda {|ids|where(["id in (?)", ids])}
  scope :unit_bills,          lambda {|unit_id|where(["bills.unit_id=?", unit_id])}
  scope :by_unit,             lambda {|unit_id|where(["unit_id=?", unit_id])}
  scope :by_device,           lambda {|device_id|where(["device_id LIKE ?", device_id])}
  scope :set_unit_in,         lambda {|unit_ids|where(["bills.unit_id in (?)", unit_ids])}
  scope :set_status,          lambda {|status|where(["bills.status=?", status])}
  scope :set_deliverable_id,  lambda {|deliverable_id|where(["bills.deliverable_id=?", deliverable_id])}
  scope :set_deliverable_type,lambda {|deliverable_type|where(["bills.deliverable_type=?", deliverable_type.capitalize])}
  scope :today,               lambda { where(["created_at > ?",Time.zone.now.beginning_of_day]) }
  scope :last_week,           lambda { where(["bills.created_at > ?",7.day.ago.beginning_of_day]) }
  scope :last_month,          lambda { where(["bills.created_at > ?",30.day.ago.beginning_of_day]) }
  scope :settled_bills,       lambda { where(["status = ?",'paid']) }
  scope :valid_bill,          lambda { where("bills.status NOT IN ('no_charge','void','cancled')")}
  scope :take_away_bill,      lambda { where("deliverable_type NOT IN ('Section','Table')")}
  scope :invalid_bill,        lambda { where("status IN ('no_charge','void','cancled')")}
  scope :nc_bill,             lambda { where("status IN ('no_charge')")}
  scope :without_serial,      lambda { where("(device_id = '') IS NOT FALSE")}
  scope :void_bill,           lambda { where("status IN ('void')")}
  scope :cod_sale,            lambda { where("status IN ('cod')")}
  scope :by_date_range,       lambda {|from_date, upto_date|where('bills.created_at BETWEEN ? AND ?',from_date,upto_date)}
  scope :section_bill,        lambda {|deliverable_id|where(["bills.deliverable_id=? and bills.deliverable_type = ?", deliverable_id,'Section'])}
  scope :by_user_login,       lambda {|login| where("(deliverable_id = ?  AND deliverable_type = 'Customer') OR  (deliverable_id IN (?)  AND deliverable_type = 'Address' )",Customer.by_identification(login).first,Customer.by_identification(login).first.addresses.pluck(:id))}
  scope :by_paymentmode_type, lambda {|paymentmode| joins(:payments).where(payments: { paymentmode_type: paymentmode })}
  scope :by_user_login,       lambda {|login| where("(deliverable_id = ?  AND deliverable_type = 'Customer') OR  (deliverable_id IN (?)  AND deliverable_type = 'Address' )",Customer.by_identification(login).first,Customer.by_identification(login).first.addresses.pluck(:id))}
  scope :boh_bill,            lambda {where("status = ?",'boh')}
  scope :bill_customer_group, -> {select("SUM(grand_total) AS grand_total,SUM(boh_amount) AS boh_amount,customer_id").group(' customer_id')
}   
  scope :bill_customer_group_cod, -> {select("SUM(grand_total) AS grand_total, customer_id").group(' customer_id')
}
  scope :cod_bill,            lambda {where("status = ?",'cod')}    
  scope :by_biller,           lambda {|biller_id| where(["biller_id=?",biller_id])}
  scope :by_resource_type,    lambda {|resource_type|where(["resource_type=?", resource_type])}
  scope :by_customer,         lambda {|customer_id| where (["customer_id = ?",customer_id])}
  scope :greater_than_id,     lambda {|last_id| where (["id > ?",last_id])}
  scope :set_ids,             lambda {|ids| where(["id in (?)",ids])}
  scope :by_section,          lambda {|section_id| where(["bills.section_id=?", section_id])}           
  scope :by_bill_destination, lambda {|bill_destination| where(["bill_destination_id=?", bill_destination])}
  scope :set_device,          lambda {|device_id| where(["bills.device_id=?", device_id])}
  scope :only_discount_bills, lambda { where("bills.discount > 0")}
  scope :by_stores, lambda { |store_ids| joins(:orders).merge(Order.set_store_id_in(store_ids))}
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
      if initialized.key?('biller_type')
        self.biller_type = self.biller_type.camelize
      end
      if !initialized.key?('serial_no')
        self.serial_no = generate_serial_number
      end
      if !initialized.key?('boh_amount')
        self.boh_amount = 0
      end
      if !initialized.key?('recorded_at')
        self.recorded_at = Time.now.utc
      else
        self.recorded_at = self.recorded_at.utc
      end
      if !initialized.key?('section_id')
        self.section_id = self.bill_orders.first.order.section_id
      end
      if !initialized.key?('customer_id')
        self.customer_id = self.bill_orders.first.order.customer_id
      end
    end
  end

  #distinct section for bills
  def self.distinct_section
    distinct_section = Bill.select("DISTINCT(deliverable_id)").where(:deliverable_type=>"Section")
  end

  # Custom validation for new bill.
  def validate_bill
    if new_record?
      ensure_bill_has_orders # This function is making conflict with V1 API
      ensure_orders_are_unbilled
      ensure_all_orders_are_not_canceled
      ensure_bill_not_duplicate
    end
  end

  # Check to see if atleast one order item
  # is present in bill.
  def ensure_bill_has_orders
    errors.add(:base, I18n.t(:error_no_orders_found_for_bill)) unless self.bill_orders.present?
  end

  # Check to see if all orders are unbilled or not.
  def ensure_orders_are_unbilled
    self.bill_orders.map { |e|  errors.add(:base, I18n.t(:error_order_billed, order: e.order_id)) if e.order.billed? }
  end

  def ensure_all_orders_are_not_canceled
    canceled_order_array = Array.new
    oreder_array = Array.new
    self.bill_orders.map { |e| canceled_order_array.push e if e.order.trash==1 }
    self.bill_orders.map { |e| oreder_array.push e }
    if canceled_order_array.count == oreder_array.count
      errors.add(:base, I18n.t(:error_canceled_order))
    end
  end

  def ensure_bill_not_duplicate
    data =Bill.select("recorded_at").where(:serial_no=>self.serial_no).last
    if data.present?
      if (data.recorded_at - self.recorded_at).to_i.abs < 10
        errors.add(:base, I18n.t(:error_duplicate_bill))
      end
    else
    end
  end

  # Setting default attributes
  def set_attributes
    self.bill_amount = compute_bill_amount
    self.tax_amount  = compute_tax_amount
    self.discount    = compute_discount
    self.delivery_charges = compute_delivery_charges
    self.roundoff    = compute_roundoff
    self.advance_payment = compute_advance_payment
    self.grand_total = compute_grand_total
  end

  def remove_service_charge
    self.bill_orders.map { |e| e.order.order_details.map { |o| o.remove_service_charge }} if self.is_service_charge == 'no'
  end

  # Calculate advance payment for tabletapp
  def compute_advance_payment
    #self.bill_orders.map { |e| e.order.advance_payment }.sum.round(2)
    self.bill_orders.map { |e| e.order.advance_payment }.sum
  end

  # Calculate delivery charges

  def compute_delivery_charges
    #self.bill_orders.map { |e| e.order.delivery_charges }.sum.round(2)
    self.bill_orders.map { |e| e.order.delivery_charges }.sum
  end

  # Calculate total bill amount before applying any tax
  # and discounts
  def compute_bill_amount
    #self.bill_orders.map { |e| e.order.order_total_without_tax }.sum.round(2)
    self.bill_orders.map { |e| e.order.order_total_without_tax }.sum
  end

  # Compute total tax amount.
  def compute_tax_amount
    #self.bill_orders.map { |e| e.order.total_tax }.sum.round(2)
    self.bill_orders.map { |e| e.order.total_tax }.sum
  end

  def bill_amount_with_tax
    self.bill_amount + self.tax_amount
  end

  # Compute sum of all appicable discounts.
  def compute_discount
    tem_array = Array.new
    #discount = self.bill_discounts.map { |e| e.discount_amount }.sum.round(2)
    self.bill_discounts.map { |e| tem_array.push e if e.is_merchant_discount == "true"}
    discount = tem_array.map { |e| e.discount_amount }.sum
    discount = bill_amount_with_tax if discount > bill_amount_with_tax
    return discount
  end

  # Compute payable amount for a bill
  def compute_grand_total
    total = bill_roundoff_disabled? ? compute_raw_grand_total : compute_raw_grand_total.round
  end

  # Compute grand total after calculating tax amount
  # and applicable discounts. This function will return
  # total before any roundoff operation.
  def compute_raw_grand_total
    self.bill_amount.to_f + self.tax_amount.to_f + self.delivery_charges.to_f - self.discount.to_f - self.advance_payment.to_f
  end

  # Compute roundoff value on grand total
  def compute_roundoff
    (compute_grand_total - compute_raw_grand_total)
  end




  # Compute payable amount for a bill
  def self.compute_grand_total_on_bill bill, discount
    total = AppConfiguration.get_config_value('apply_bill_roundoff') == 'disabled' ? compute_raw_grand_total_on_bill(bill, discount) : compute_raw_grand_total_on_bill(bill, discount).round
  end

  # Compute grand total after calculating tax amount
  # and applicable discounts. This function will return
  # total before any roundoff operation.
  def self.compute_raw_grand_total_on_bill bill, discount
    bill.bill_amount.to_f + bill.tax_amount.to_f - discount.to_f
  end


  # Creates new tax charges if there are any applicable rates. If prices already
  # include taxes then price adjustments are created instead.
  # def create_tax_charge!
  #   return if self.invalid_bill?
  #   clear_tax_entries_if_exist!   
  #   self.bill_orders.map { |e| (e.order.order_details.map { |o|
  #     discount_percentage = o.discount_percentage!= nil ? o.discount_percentage : 0
  #       (JSON.parse(o.tax_details).map { |t|
  #         amount = (t['tax_amount'].to_f * o.quantity) - ((t['tax_amount'].to_f * o.quantity) * discount_percentage)/100
  #         add_or_update_tax_entry t['tax_class_id'], amount } if JSON.parse(o.tax_details).present? 
  #       ) if o.trash == 0 and o.tax_details.present?
  #     }) if e.order.trash == 0
  #   }
  #   if self.is_service_charge == 'no'
  #     _bill_tax_amount = 0
  #     _bill_tax_amount = self.bill_tax_amounts.sum :tax_amount if self.bill_tax_amounts.present?
  #     self.update_column(:tax_amount, _bill_tax_amount)
  #     self.update_column(:grand_total, compute_grand_total) 
  #   end     
  # end

  def create_tax_charge!
    return if self.invalid_bill?
    clear_tax_entries_if_exist!   
    self.bill_orders.map { |e| (e.order.order_details.map { |o|
        (JSON.parse(o.tax_details).map { |t|
          add_or_update_tax_entry t['tax_class_id'], (t['tax_amount'].to_f * o.quantity) } if JSON.parse(o.tax_details).present?
        ) if o.trash == 0 and o.tax_details.present?
      }) if e.order.trash == 0
    }    
    if self.is_service_charge == 'no'
      _bill_tax_amount = 0
      _bill_tax_amount = self.bill_tax_amounts.sum :tax_amount if self.bill_tax_amounts.present?
      self.update_column(:tax_amount, _bill_tax_amount)
      self.update_column(:grand_total, compute_grand_total)
    end 
    self.bill_by_bill_sale.update_json_data
  end

  # def create_tax_charge
  #   return if self.invalid_bill?
  #   if AppConfiguration.get_config_value('discount_on_subtotal') == 'enabled'
  #     clear_tax_entries_if_exist!
  #     (JSON.parse(self.bill_orders.first.order.order_details.first.tax_details).map { |t|
  #       add_or_update_tax_entry t['tax_class_id'], ((self.bill_amount - self.discount) * (t["tax_percentage"]/100)) } if JSON.parse(self.bill_orders.first.order.order_details.first.tax_details).present?
  #     ) if self.bill_orders.first.order.order_details.first.trash == 0 and self.bill_orders.first.order.order_details.first.tax_details.present?
  #   end  
  # end

  def upate_bill
    if AppConfiguration.get_config_value('discount_on_subtotal') == 'enabled'
      if self.discount > 0
        amount = 0
        self.bill_tax_amounts.each do |tax|
          if tax.tax_amount > 0
            amount += tax.tax_amount if tax.tax_class.tax_type == "parcel_charge"
          end       
        end
        discount_percentage = (self.discount / (self.bill_amount + amount))*100
        self.bill_tax_amounts.each do |tax|
          if tax.tax_amount > 0
            discount_on_tax tax.tax_class_id, discount_percentage if tax.tax_class.tax_type != "parcel_charge"
          end       
        end
        if self.tax_amount > 0 
          _bill_total_tax = self.bill_tax_amounts.sum :tax_amount
          self.update_column(:tax_amount, _bill_total_tax)
        end
        if self.void? || self.no_charge?
          self.update_column(:grand_total, 0)  
          self.bill_tax_amounts.destroy_all
          self.settlement.payments.map { |payment| payment.paymentmode.destroy } if self.settlement.present? and self.settlement.payments.present?
          self.settlement.payments.destroy_all if self.settlement.present? and self.settlement.payments.present?
          self.settlement.destroy if self.settlement.present?
        else  
          self.update_column(:grand_total, compute_grand_total)  
          #re_compute_amount! if self.bill_discount_percentage.present?
        end  
      end    
    end  
  end

  # Change Bill Roundoff Base On Split Bill # ABDUL
  def change_bill_roundoff_base_on_split_bill
    if self.bill_splits.present?
      _total_split_bill_gt = 0
      self.bill_splits.each do |bs|
        _total_split_bill_gt = _total_split_bill_gt + bs.grand_total.round
      end

      if _total_split_bill_gt != self.grand_total
        _m_roundoff = (_total_split_bill_gt - self.grand_total)
        _m_gt = (self.grand_total + _m_roundoff)
        self.update_column(:split_roundoff, _m_roundoff)
        self.update_column(:grand_total, _m_gt)
      end
    end
  end

  # Delete previous tax details if exist
  def clear_tax_entries_if_exist!
    self.bill_tax_amounts.delete_all if self.bill_tax_amounts.present?
  end

  # Add or update tax entry for bill
  def add_or_update_tax_entry tax_class_id, amount
    tax_entry = self.bill_tax_amounts.by_tax_id(tax_class_id).first
    if tax_entry.present?
      tax_entry.update_attribute(:tax_amount, tax_entry.tax_amount + amount)
    else
      self.bill_tax_amounts.create(:tax_class_id=>tax_class_id,:tax_amount=>amount)
    end
  end

  def discount_on_tax tax_class_id, discount_percentage
    tax_entry = self.bill_tax_amounts.by_tax_id(tax_class_id).first
    if tax_entry.present?
      _tax_amount = tax_entry.tax_amount-((tax_entry.tax_amount * discount_percentage)/100)
      tax_entry.update_attribute(:tax_amount, _tax_amount)
    end 
  end

  def invalid_bill?
    self.void? || self.no_charge?
  end

  def paid!
    update_column(:status, 'paid')    
    self.bill_by_bill_sale.update_payment_data
    send_sms
    send_email
    #if AppConfiguration.get_config_value('order_confirm_after_payment') == 'enabled'
    if self.orders.first.order_status_id == 11
      self.orders.each do |order|
        order.update_attribute(:order_status_id, 1)
      end  
      if self.orders.first.order_status_id == 1
        _subdomain = AppConfiguration.find_by_config_key('site_id')
        _channels = Array.new
        _channels.push '/notifications/android/subdomain/'+_subdomain.config_value.to_s+'/unit/'+self.unit_id.to_s+'/new_order'
        _channels.push '/notifications/portal/subdomain/'+_subdomain.config_value.to_s+'/unit/'+self.unit_id.to_s+'/new_order'
        Notification.publish_in_faye(_channels,{:order => self.orders.first})
      end  
    end  
  end

  def boh_amount!
    update_column(:boh_amount, self.grand_total - self.settlement.split_settlements.map { |e| e.bill_split_ammount }.sum)
  end

  def re_compute_amount!
    # _bill_tax_amount = 0
    # _bill_tax_amount = self.bill_tax_amounts.sum :tax_amount if self.bill_tax_amounts.present?
    # if self.bill_discount_percentage == 100
    #   self.update_column(:tax_amount, 0)
    #   self.update_column(:grand_total, 0) 
    # else  
    #   self.update_column(:tax_amount, _bill_tax_amount)
    #   self.update_column(:grand_total, compute_grand_total) 
    # end  
    # if self.settlement.present?
    #   self.settlement.update_column(:bill_amount,self.grand_total)
    #   if self.settlement.payments.present?
    #     self.settlement.payments.each do |payment|
    #       payment.paymentmode.update_column(:amount, payment.paymentmode.amount - (payment.paymentmode.amount * self.bill_discount_percentage)/100)
    #     end 
    #   end  
    # end  
  end

  # Return true if bill roundoff is disabled
  def bill_roundoff_disabled?
    AppConfiguration.get_config_value('apply_bill_roundoff') == 'disabled'
  end

  def generate_serial_number
    serial_number = "#{self.unit_id}-#{self.device_id}-1"
    if self.device_id.present?
      _last_bill = Bill.by_device(self.device_id).by_unit(self.unit_id).last
      if _last_bill.present? && _last_bill.serial_no.present?
        _serial = _last_bill.serial_no.split("-")
        _serial_no = _serial[2].to_i + 1
        serial_number = "#{self.unit_id}-#{self.device_id}-#{_serial_no}"
      end
    end
    return serial_number
  end
  # ------------------
  def self.bill_exist(order_sr_no)
    Bill.find_by_order_sr_no(order_sr_no)
  end

  def self.by_order_source source
    includes([:orders]).where("orders.source" => source)
  end

  def self.update_bill_amounts _bill
    _bill_subtotal_without_tax = _bill.orders.sum :order_total_without_tax
    if AppConfiguration.get_config_value('discount_on_subtotal') == 'enabled'
      _bill_total_tax = _bill.bill_tax_amounts.sum :tax_amount
    else  
      _bill_total_tax = _bill.orders.sum :total_tax
    end  
    _bill_subtotal = _bill.orders.sum :order_subtotal
    _grand_total = _bill.bill_roundoff_disabled? ? (_bill_subtotal - _bill.discount.to_f) : (_bill_subtotal - _bill.discount.to_f).round
    _bill.update_column(:grand_total, _grand_total)
    _bill.update_column(:tax_amount, _bill_total_tax)
    _bill.update_column(:bill_amount, _bill_subtotal_without_tax)
    if _grand_total <= 0
      _bill.update_column(:status, 'cancled')
      #_bill.bill_tax_amounts.destroy_all
      #_bill.settlement.payments.map { |payment| payment.paymentmode.destroy } if _bill.settlement.present? and _bill.settlement.payments.present?
      #_bill.settlement.payments.destroy_all if _bill.settlement.present? and _bill.settlement.payments.present?
      #_bill.settlement.destroy if _bill.settlement.present?
    end  
  end

  def self.calculate_bill_taxes _bill
    _bill.bill_tax_amounts.delete_all if _bill.bill_tax_amounts.present? #Delete previous tax details if exist
    _tax_hash = {}
    _bill.orders.each do |order|
      # Tax details calculation
      order.order_details.each do |od|
        if od.trash == 0 and od.tax_details.present?
          _tax_json = JSON.parse(od.tax_details)
          if _tax_json.present?
            _tax_json.each do |tj|
              _class_amount = (tj["tax_amount"].to_f * od.quantity)
              if _tax_hash.has_key?(tj['tax_class_id'])
                _tax_hash[tj["tax_class_id"]] = _tax_hash[tj["tax_class_id"]].to_f + _class_amount
              else
                _tax_hash[tj["tax_class_id"]] = _class_amount
              end
            end
          end
        end
      end
    end
    _tax_hash.each do |key,value|
      _bill_tax = BillTaxAmount.new(:tax_class_id=>key,:tax_amount=>value)
      _bill.bill_tax_amounts << _bill_tax
    end
  end

  def self.apply_promo_code(_bill,_promo_code)
    _code = AlphaPromotion.find_by_promo_code(_promo_code)
    raise "Promo code #{_promo_code} is invalid" unless _code.present?
    _discount = _code.promo_value if _code.promo_type == "by_amount"
    if AppConfiguration.get_config_value('discount_on_subtotal') == 'enabled'
      _discount = (_bill.bill_amount * _code.promo_value / 100) if _code.promo_type == "by_percentage"
    else  
      _discount = (_bill.grand_total * _code.promo_value / 100) if _code.promo_type == "by_percentage"
    end  
    _discount = _bill.grand_total if _discount > _bill.grand_total
    _bill.bill_discounts << BillDiscount.new(:discount_amount=>_discount.round, :remarks=>"Promo code #{_promo_code} applied")
    if AppConfiguration.get_config_value('discount_on_subtotal') == 'enabled'
      _bill.bill_tax_amounts.delete_all if _bill.bill_tax_amounts.present?
      (JSON.parse(_bill.bill_orders.first.order.order_details.first.tax_details).map { |t|
        tax_entry = _bill.bill_tax_amounts.by_tax_id(t['tax_class_id']).first
        if tax_entry.present?
          tax_entry.update_attribute(:tax_amount, tax_entry.tax_amount + ((_bill.bill_amount - _discount) * (t["tax_percentage"]/100)).round(2))
        else
          _bill.bill_tax_amounts.create(:tax_class_id=>t['tax_class_id'],:tax_amount=>((_bill.bill_amount - _discount) * (t["tax_percentage"]/100)).round(2))
        end  
        }  
      ) if _bill.bill_orders.first.order.order_details.first.trash == 0 and _bill.bill_orders.first.order.order_details.first.tax_details.present?
      _bill_total_tax = _bill.bill_tax_amounts.sum :tax_amount
      _bill.update_attribute(:tax_amount, _bill_total_tax)
      _grand_total = compute_grand_total_on_bill(_bill, _discount)
      _bill.update_attribute(:grand_total, _grand_total)
    end  
  end

  def update_reservation
    Reservation.find(self.reservation_id).update_column(:bill_id, self.id) if self.reservation_id.present?
    #self.reservation.update_column(:bill_id, self.id) if self.reservation.present?
  end

  def save_in_bill_by_bill_sale
    bill_by_bill_sale = BillByBillSale.new()
    bill_by_bill_sale.attributes = self.to_hash.slice(*BillByBillSale.accessible_attributes)
    bill_by_bill_sale.bill_id = self.id
    bill_by_bill_sale.save
  end
  
  def update_proforma_as_billed
    if self.proforma_id.present?
      _proforma = Proforma.find(self.proforma_id)
      _proforma.update_attribute(:billed, 1) if _proforma.present?
    end  
  end

  def self.check_bill_status(status)
    if !status.empty?
      where('bills.status IN(?)',status)
    else
      all
    end
  end

  def self.check_price_range(from_price, to_price)
    if !from_price.empty? && !to_price.empty?
      where('grand_total between ? and ?',from_price,to_price)
    else
      all
    end
  end

  def self.check_bill_date_range(from_date, upto_date)
    where('bills.created_at BETWEEN ? AND ?',from_date,upto_date)
  end

  def self.check_bill_by_date(from_date, upto_date)
    where('date(bills.created_at) BETWEEN ? AND ?',from_date,upto_date)
  end

  def self.by_recorded_at(from_date, upto_date)
    where('bills.recorded_at BETWEEN ? AND ?',from_date,upto_date)
  end

  def self.third_party_payment_load(payment_option_id)
    joins("
      INNER JOIN third_party_payments
      ON (third_party_payments.third_party_payment_option_id in (#{payment_option_id.join(",")}) AND third_party_payments.id=payments.paymentmode_id)
    ")
  end

  def self.coupon_payment_load(payment_option_id)
    joins("
      INNER JOIN coupon_payments
      ON (coupon_payments.coupon_id in (#{payment_option_id.join(",")}) AND coupon_payments.id=payments.paymentmode_id)
    ")
  end

  def self.last_serial_number(unit_id,device_id)
    data_with_no_device = Bill.unit_bills(unit_id).without_serial #blank array for no update require
    unless data_with_no_device.empty?
      data_with_no_device.update_all(:device_id=>device_id)
      data = Bill.where(:unit_id => unit_id,:device_id=>device_id).select("id").order("id")
      data.each_with_index{|item,index| Bill.update(item.id, serial_no: "#{unit_id}-#{device_id}-#{index+1}")}
    end

    last_serial_no = Bill.select("MAX(REPLACE(serial_no,'-','')::bigint) AS serial_no").group(:id).where(:unit_id=>unit_id,:device_id=>device_id).first
    last_serial_no.present? ? last_serial_no.serial_no.gsub!("#{unit_id}#{device_id}", ''): 0
  end

  def self.last_section_bill_serial_number(unit_id,device_id,section_id)
    data_with_no_device = Bill.unit_bills(unit_id).by_section(section_id).without_serial #blank array for no update require
    unless data_with_no_device.empty?
      data_with_no_device.update_all(:device_id=>device_id)
      data = Bill.where(:unit_id => unit_id,:device_id=>device_id, :section_id=>section_id).select("id").order("id")
      data.each_with_index{|item,index| Bill.update(item.id, serial_no: "#{unit_id}-#{section_id}-#{device_id}-#{index+1}")}
    end

    last_serial_no = Bill.select("MAX(REPLACE(serial_no,'-','')::bigint) AS serial_no").group(:id).where(:unit_id=>unit_id,:device_id=>device_id, :section_id=>section_id).first
    last_serial_no.present? ? last_serial_no.serial_no.gsub!("#{unit_id}#{section_id}#{device_id}", ''): 0
  end

  def self.last_bill_destination_serial_number(unit_id,device_id,bill_destination_id)
    data_with_no_device = Bill.unit_bills(unit_id).by_bill_destination(bill_destination_id).without_serial #blank array for no update require
    unless data_with_no_device.empty?
      data_with_no_device.update_all(:device_id=>device_id)
      data = Bill.where(:unit_id => unit_id,:device_id=>device_id, :bill_destination_id=>bill_destination_id).select("id").order("id")
      data.each_with_index{|item,index| Bill.update(item.id, serial_no: "#{unit_id}-#{bill_destination_id}-#{device_id}-#{index+1}")}
    end

    last_serial_no = Bill.select("MAX(REPLACE(serial_no,'-','')::bigint) AS serial_no").group(:id).where(:unit_id=>unit_id,:device_id=>device_id, :bill_destination_id=>bill_destination_id).first
    last_serial_no.present? ? last_serial_no.serial_no.gsub!("#{unit_id}#{bill_destination_id}#{device_id}", ''): 0
  end

  def self.get_unit_bill_data(unit_id,from_datetime,to_datetime)
    total_sale = 0
    total_sale = Bill.unit_bills(unit_id).by_recorded_at(from_datetime,to_datetime).sum(:grand_total)
    return total_sale
  end

  def self.get_unit_settlement_data(unit_id,from_datetime,to_datetime)

    settlement_data = {}
    settlement_data[:card_sale]=Card.where(:id=>Bill.unit_bills(unit_id).valid_bill.by_recorded_at(from_datetime,to_datetime).joins(:payments).where(payments: { paymentmode_type: 'Card' }).pluck(:paymentmode_id)).sum(:amount).to_f
    settlement_data[:cash_sale]=Cash.where(:id=>Bill.unit_bills(unit_id).valid_bill.by_recorded_at(from_datetime,to_datetime).joins(:payments).where(payments: { paymentmode_type: 'Cash' }).pluck(:paymentmode_id)).sum(:amount).to_f
    settlement_data[:loyalty_card_sale]=LoyaltyCardPayment.where(:id=>Bill.unit_bills(unit_id).valid_bill.by_recorded_at(from_datetime,to_datetime).joins(:payments).where(payments: { paymentmode_type: 'LoyaltyCardPayment' }).pluck(:paymentmode_id)).sum(:amount).to_f
    settlement_data[:third_party_sale]=ThirdPartyPayment.where(:id=>Bill.unit_bills(unit_id).valid_bill.by_recorded_at(from_datetime,to_datetime).joins(:payments).where(payments: { paymentmode_type: 'ThirdPartyPayment' }).pluck(:paymentmode_id)).sum(:amount).to_f
    settlement_data[:coupon_sale]=CouponPayment.where(:id=>Bill.unit_bills(unit_id).valid_bill.by_recorded_at(from_datetime,to_datetime).joins(:payments).where(payments: { paymentmode_type: 'CouponPayment' }).pluck(:paymentmode_id)).sum(:amount).to_f
    settlement_data[:wallet_sale]=WalletTransaction.where(:id=>Bill.unit_bills(unit_id).valid_bill.by_recorded_at(from_datetime,to_datetime).joins(:payments).where(payments: { paymentmode_type: 'WalletTransaction' }).pluck(:paymentmode_id)).sum(:amount).to_f
    settlement_data[:total_settlement] = settlement_data[:card_sale]+settlement_data[:cash_sale]+settlement_data[:loyalty_card_sale]+settlement_data[:third_party_sale]+settlement_data[:wallet_sale]+settlement_data[:coupon_sale]

    return settlement_data
  end

  def self.get_device_settlement_data(unit_id,from_datetime,to_datetime,device_id)

    settlement_data = {}
    settlement_data[:card_sale]=Card.where(:id=>Bill.unit_bills(unit_id).valid_bill.by_recorded_at(from_datetime,to_datetime).set_device(device_id).joins(:payments).where(payments: { paymentmode_type: 'Card' }).pluck(:paymentmode_id)).sum(:amount)
    settlement_data[:cash_sale]=Cash.where(:id=>Bill.unit_bills(unit_id).valid_bill.by_recorded_at(from_datetime,to_datetime).set_device(device_id).joins(:payments).where(payments: { paymentmode_type: 'Cash' }).pluck(:paymentmode_id)).sum(:amount)
    settlement_data[:loyalty_card_sale]=LoyaltyCardPayment.where(:id=>Bill.unit_bills(unit_id).valid_bill.by_recorded_at(from_datetime,to_datetime).set_device(device_id).joins(:payments).where(payments: { paymentmode_type: 'LoyaltyCardPayment' }).pluck(:paymentmode_id)).sum(:amount)
    settlement_data[:third_party_sale]=ThirdPartyPayment.where(:id=>Bill.unit_bills(unit_id).valid_bill.by_recorded_at(from_datetime,to_datetime).set_device(device_id).joins(:payments).where(payments: { paymentmode_type: 'ThirdPartyPayment' }).pluck(:paymentmode_id)).sum(:amount)
    settlement_data[:wallet_sale]=WalletTransaction.where(:id=>Bill.unit_bills(unit_id).valid_bill.by_recorded_at(from_datetime,to_datetime).set_device(device_id).joins(:payments).where(payments: { paymentmode_type: 'WalletTransaction' }).pluck(:paymentmode_id)).sum(:amount)
    settlement_data[:total_settlement] = settlement_data[:card_sale]+settlement_data[:cash_sale]+settlement_data[:loyalty_card_sale]+settlement_data[:third_party_sale]+settlement_data[:wallet_sale]

    return settlement_data
  end

  def self.by_date_sales_data(unit_id,from_date,to_date)
    data = {}
    total_card_sale = 0
    total_cash_sale = 0
    other_sale = 0
    total_sale = 0
    _data = Bill.unit_bills(unit_id).check_bill_by_date(from_date,to_date)
    _data.each do |data|
      if data.settlement.present?
        payments = data.settlement.payments
        payments.each do |payment|
          total_sale += payment.paymentmode['amount']
          if payment['paymentmode_type'] == "Cash"
            total_cash_sale += payment.paymentmode['amount']
          elsif payment['paymentmode_type'] == "Card"
            total_card_sale += payment.paymentmode['amount']
          else
            other_sale += payment.paymentmode['amount']
          end
        end
      end
    end
    data[:total_card_sell] = total_card_sale.round(2)
    data[:total_cash_sell] = total_cash_sale.round(2)
    data[:other_sale]      = other_sale.round(2)
    return data
  end

  def self.tax_persentage_group_amount(unit_id,dates)
    _bills_tax_group=Array.new
    
    dates.each do |date|
      _unit_detail_options = Unit.find(unit_id).unit_detail.options if Unit.find(unit_id).unit_detail.present?
      date = date.to_date
      _from_datetime = date.to_date.beginning_of_day+_unit_detail_options[:day_closing_time].to_i.hours if Unit.find(unit_id).unit_detail.present?
      _from_datetime ||= date.to_date.beginning_of_day
      _to_datetime = date.to_date.end_of_day+_unit_detail_options[:day_closing_time].to_i.hours if Unit.find(unit_id).unit_detail.present?
      _to_datetime ||= date.to_date.end_of_day
      _data = Bill.unit_bills(unit_id).by_recorded_at(_from_datetime,_to_datetime).valid_bill
      _data.each do |bl|
        _bill_tax_data=bl.bill_tax_amounts
        _bill_tax_data.each do |btd|
          if btd.tax_class.tax_type == "variable" || btd.tax_class.tax_type == "simple" 
            bill_id_hash = {}
            bill_id_hash["created_at"] = date
            bill_id_hash["tax_persentage"] = btd.tax_class.ammount
            bill_id_hash["tax_persentage_group"] = btd.tax_class.ammount*2
            bill_id_hash["tax_class_id"] = btd.tax_class.id
            bill_id_hash["tax_amount"] = btd.tax_amount
            bill_id_hash["taxable_amount"] = (100*btd.tax_amount)/btd.tax_class.ammount
            _bills_tax_group.push bill_id_hash
          elsif btd.tax_class.tax_type == "tax_on_service"  
            bill_id_hash = {}
            bill_id_hash["created_at"] = date
            bill_id_hash["tax_persentage"] = btd.tax_class.ammount
            bill_id_hash["tax_persentage_group"] = btd.tax_class.ammount
            bill_id_hash["tax_class_id"] = btd.tax_class.id
            bill_id_hash["tax_amount"] = btd.tax_amount
            bill_id_hash["taxable_amount"] = (100*btd.tax_amount)/btd.tax_class.ammount
            _bills_tax_group.push bill_id_hash
          end
        end
      end
    end

    result1 = _bills_tax_group.group_by { |x| x.values_at('created_at', 'tax_persentage') }.map {|key, hashes|
      result = hashes[0].clone
      ['tax_amount'].each { |key|
        result[key] = hashes.inject(0) { |s, x| s + x[key].to_f }
      }
      result
    }
    return result1
  end

  def self.tax_grup_amount(unit_id,dates)
    _bills_tax_group=Array.new
    dates.each do |date|
      _unit_detail_options = Unit.find(unit_id).unit_detail.options if Unit.find(unit_id).unit_detail.present?
      date = date.to_date
      _from_datetime = date.to_date.beginning_of_day+_unit_detail_options[:day_closing_time].to_i.hours if Unit.find(unit_id).unit_detail.present?
      _from_datetime ||= date.to_date.beginning_of_day
      _to_datetime = date.to_date.end_of_day+_unit_detail_options[:day_closing_time].to_i.hours if Unit.find(unit_id).unit_detail.present?
      _to_datetime ||= date.to_date.end_of_day
      _data = Bill.unit_bills(unit_id).by_recorded_at(_from_datetime,_to_datetime).valid_bill
      _data.each do |bl|
        _bill_tax_data=bl.bill_tax_amounts
        _bill_tax_data.each do |btd|
          bill_id_hash = {}

          bill_id_hash["created_at"] = date   #.strftime('%F')
          bill_id_hash["bill_id"] = bl.id
          bill_id_hash["tax_group_id"] = btd.tax_class.tax_groups.first.id
          bill_id_hash["tax_group_name"] = btd.tax_class.tax_groups.first.name
          bill_id_hash["tax_group_amount"] = btd.tax_amount
          _bills_tax_group.push bill_id_hash
        end
      end
    end
    amount = 0
    _bills_tax_group.each do |billtax|
      amount = amount + billtax["tax_group_amount"]
    end 
    
    result1 = _bills_tax_group.group_by { |x| x.values_at('created_at', 'tax_group_id') }.map {|key, hashes|
      result = hashes[0].clone
      ['tax_group_amount'].each { |key|
        result[key] = hashes.inject(0) { |s, x| s + x[key].to_f }
      }
      result
    }
    return result1
  end

  ### Report related functions

  def self.report_attributes
    attributes = {}
    attributes['bill'] = Bill.column_names
    attributes['payment'] = Payment.uniq.pluck(:paymentmode_type)
    attributes["tax"] = TaxClass.uniq.pluck(:name)
    attributes["third_party"] = ThirdPartyPayment.uniq.pluck(:third_party_payment_option_name)
    return attributes
  end

  # def method_missing(method_name, *args, &block)
  #   if method_name.to_s == "payment"
  #     #user.send($1, *arguments, &block)
  #     data = self.payments.where(paymentmode_type: args.first.camelize).first

  #     data.amount if data
  #   elsif method_name.to_s == "tax"
  #     tax_data = self.bill_tax_amounts.joins(:tax_class).where("tax_classes.name=?",args.first).first
  #     tax_data.tax_amount if tax_data
  #   else
  #     super
  #   end
  # end

  def method_missing(method_name, *args, &block)
    if method_name.to_s == "payment"
      #user.send($1, *arguments, &block)
      data = self.payments.where(paymentmode_type: args.first.camelize).first

      data.amount if data
    elsif method_name.to_s == "tax"
      tax_data = self.bill_tax_amounts.joins(:tax_class).where("tax_classes.name=?",args.first).first
      tax_data.tax_amount if tax_data
    elsif method_name.to_s == "third_party"
      payment_amount = self.payments.where(paymentmode_type: 'ThirdPartyPayment').joins("
      INNER JOIN third_party_payments
      ON (third_party_payments.id=payments.paymentmode_id and third_party_payments.third_party_payment_option_name = '#{args.first}')
    ").first
      payment_amount.amount if payment_amount 
    else
      super
    end
  end

  def self.payment_summery(form_date,to_date,type)
      data = check_bill_date_range(form_date,to_date)
      data.inject(0){|result, data| result + (data.payment(type) || 0)}
  end

  def self.tax_summery(unit_id,from_datetime,to_datetime,type)

      data = ActiveRecord::Base.connection.execute("SELECT date(bills.recorded_at), tax_classes.name, round(CAST(SUM(bill_tax_amounts.tax_amount) as numeric),2) as total_amount FROM bills
LEFT OUTER JOIN bill_tax_amounts ON bills.id = bill_tax_amounts.bill_id
LEFT OUTER JOIN tax_classes ON bill_tax_amounts.tax_class_id = tax_classes.id WHERE  bills.status NOT IN ('no_charge','void') AND bills.recorded_at BETWEEN '#{from_datetime}' AND '#{to_datetime}' AND bills.unit_id=#{unit_id}
GROUP BY tax_classes.name,date(bills.recorded_at) HAVING tax_classes.name='#{type}'");

      tax_data = {}
      data.each do |item|
        tax_data[item['date']] = item['total_amount']
      end
      return tax_data
  end

  # Export data for Tally
  def self.to_tally_csv(device_id, bill_prefix, options = {})
    CSV.generate(options) do |csv|
      _headers = ["Voucher typename", "Inv No","Inv Date","Order Number", "Mode Of Payment","Buyer Name", "Buyer Add1", "Buyer Add2", "city", "state", "PIN", "TIN", "Item Code", "Stock Group", "Itemname", "Last serial Number", "Quantity", "Rate", "Value"]
      Bill.report_attributes.each do |key, attributes|
        if key == "tax"
          attributes.each do |attribute|
            _headers.push(attribute)
          end
        end
      end
      _headers.push("other charges")
      _headers.push("Discount1")
      _headers.push("Discount2")
      _headers.push("Round off")
      _headers.push("Invoice Amount")
      _headers.push("narration")
      csv << _headers
      @bills = Bill.valid_bill.today.by_device(device_id).order("id asc")
      @bills.each do |object|
        _payment = object.settlement.payments.first
        _order = object.bill_orders.first.order
        _order.order_details.each_with_index do |item, index|
          _row = Array.new
          _row.push("#{(index == 0) ? item.menu_product.menu_card.name : ''}")
          _serial = object.serial_no.split("-")
          _serial_no = _serial[2].to_i
          _row.push("#{bill_prefix}#{_serial_no}")
          _row.push(object.recorded_at.strftime("%d-%m-%Y %I:%M %p"))
          _row.push(_order.id)
          if index == 0
            _row.push("#{(_payment.paymentmode_type == 'Card') ? 'Credit Card' : _payment.paymentmode_type}")
          else
            _row.push("#{(index == 0) ? _payment.paymentmode_type : ''}")
          end
          if object.deliverable_type == 'Customer'
            _row.push(object.deliverable.profile.customer_name)
            _row.push("")
            _row.push("")
          elsif object.deliverable_type == 'Address'
            _row.push(object.deliverable.receiver_name)
            _delivery_address = object.deliverable.delivery_address.gsub(/,/, ' ')
            _row.push(_delivery_address)
            _row.push(_delivery_address)
          else
            _row.push(object.deliverable_type)
            _row.push("")
            _row.push("")
          end
          _row.push(object.unit.city)
          _row.push(object.unit.state)
          _row.push(object.unit.pincode)
          _row.push(object.unit.unit_detail.present? ? object.unit.unit_detail.options[:tin_number] : "")
          _row.push(item.product_unique_identity)
          _row.push(item.menu_product.menu_category.name)
          _upc = item.properties["upc"] || ''
          _inter_code = _upc.split('-')
          #_row.push("#{_inter_code[0]} #{item.item_name} #{item.menu_product.menu_category.name}")
          _row.push("#{item.item_name}")
          _row.push(item.properties["upc"] || '')
          _row.push(item.quantity)
          _row.push(item.unit_price_without_tax)
          _row.push(item.quantity * item.unit_price_without_tax)
          _tax_details = JSON.parse(item.tax_details)
          _item_tax_amount = 0
          Bill.report_attributes.each do |key, attributes|
            if key == "tax"
              attributes.each do |attribute|
                _tax_details.each do |tax|
                  _tax_class_amount = (tax["tax_class_name"] == attribute) ? (tax["tax_amount"].to_f * item.quantity) : 0
                  _item_tax_amount += _tax_class_amount
                  _row.push(_tax_class_amount.round(2))
                end
              end
            end
          end
          _item_price_with_tax = ((item.quantity * item.unit_price_without_tax) + _item_tax_amount)
          _item_discount_share = (_item_price_with_tax * object.discount) / (object.bill_amount + object.tax_amount)
          _row.push("0")
          _row.push(_item_discount_share.round(2))
          _row.push("0")
          _row.push("#{(index == 0) ? object.roundoff : ''}")
          _row.push("#{(index == 0) ? object.grand_total : ''}")
          _row.push(object.remarks)
          csv << _row
        end
      end
    end
  end

  # Data export to CSV
  def self.by_date_sales_to_csv(user_unit_id,unit_id,bills,total_bill,from_datetime,to_datetime,deliver_type)
    CSV.generate do |csv|
      preferences = ReportPreference.by_unit(user_unit_id).by_key('sales_report_by_date').first
      _pref = preferences.present? ? JSON.parse(preferences.allowed_attributes) : ["bill_id","deliverables_at","bill_amount_without_tax","total_tax","discount","total","status","user","remarks"]
      _pref_humanize =  _pref.map{|x| (x.humanize)}
      _pref_humanize = _pref_humanize.push("Apc") if deliver_type.present? &&  deliver_type == 'Resource'
      csv << _pref_humanize
      bills.each do |bill|
        _row = Array.new
        _row.push(bill.id) if _pref.include?('bill_id')
        _row.push("#{bill.prefix}""#{bill.serial_no}""#{bill.suffix}") if _pref.include?('bill_serial')
        _row.push(bill.orders.first.source) if _pref.include?('order_source')
        if bill.orders.first.present?
          _order = bill.orders.first
          if ['Address','Customer'].include?(_order.deliverable_type)
            _row.push(_order.deliverable_type) if _pref.include?('deliverables_at')
          else
            _row.push("#{_order.deliverable.name} (##{_order.deliverable_id})") if _pref.include?('deliverables_at') ##{_order.deliverable_type}: 
          end
        else
          _row.push("_")
        end
        _row.push(bill.bill_amount) if _pref.include?('bill_amount_without_tax')
        _row.push(bill.tax_amount) if _pref.include?('total_tax')
        _row.push(bill.discount) if _pref.include?('discount')
        _row.push(bill.grand_total) if _pref.include?('total')
        if bill.deliverable_type == 'Resource'
          _row.push(bill.pax) if _pref.include?('pax')
        else
          _row.push('-') if _pref.include?('pax')
        end  
        _row.push(bill.roundoff) if _pref.include?('roundoff')
        _row.push(bill.status) if _pref.include?('status')
        _row.push("#{bill.biller.profile.firstname} #{bill.biller.profile.lastname}") if _pref.include?('user')
        _row.push(bill.remarks) if _pref.include?('remarks')
        _row.push("#{bill.recorded_at.strftime('%d-%m-%Y, %I:%M %p')}") if _pref.include?('date')
        _row.push("#{bill.created_at.strftime('%d-%m-%Y, %I:%M %p')}") if _pref.include?('created_at')
        _customer_name = bill.customer.present? ? "#{bill.customer.customer_profile.firstname} #{bill.customer.customer_profile.lastname} (#{bill.customer.customer_profile.contact_no})" : "-"
        _row.push(_customer_name) if _pref.include?('customer')
        _section_name = bill.section.present? ? bill.section.name : "-"
        _row.push(_section_name) if _pref.include?('section_name')
        _row.push(bill.orders.first.third_party_order_id) if _pref.include?('third_party_order_id')

        Bill.report_attributes.each do |key, attributes|
          if key == "payment"
            attributes.each do |attribute|
              _row.push(bill.payment(attribute)) if _pref.include?(attribute.parameterize)
            end
          end
          if key == "tax"
            attributes.each do |attribute|
              _row.push(bill.tax(attribute)) if _pref.include?(attribute.parameterize)
            end
          end
          if key == "third_party"
            attributes.each do |attribute|
              _row.push(bill.third_party(attribute)) if _pref.include?(attribute.parameterize)
            end
          end
        end
        _row.push((bill.grand_total / bill.pax).round(2)) if deliver_type.present? &&  deliver_type == 'Resource'
        csv << _row
      end
      _blank = Array.new
      _blank.push()
      csv<<_blank
      settlement_data = Bill.get_unit_settlement_data(unit_id,from_datetime,to_datetime)
      third_party_settlements = Bill.get_unit_third_party_settlement_data(unit_id,from_datetime,to_datetime)
      third_party_payment_options = ThirdPartyPayment.uniq.pluck(:third_party_payment_option_name)
      _totalpref = ["Total Bill amount Without Tax","Total Tax","Total Discount","Total Roundoff","Total Bill amount with tax","Cash","Card","Loyalty Card","Third Party"]
      if deliver_type.present? &&  deliver_type == 'Resource'
        _totalpref = _totalpref.insert(5, 'Total Pax','Apc')
      else
        _totalpref = _totalpref.insert(5, 'Total Pax','Apc')
      end  
      third_party_payment_options.each do |tppo|
        _totalpref.push(tppo) if _pref.include?(tppo)
      end
      _totalpref_humanize =  _totalpref.map{|x| (x.humanize)}
      csv<<_totalpref_humanize
      _total = Array.new
      _total.push(total_bill[0].total_bill_amount)
      _total.push(total_bill[0].total_tax)
      _total.push(total_bill[0].total_discount)
      _total.push(total_bill[0].total_roundoff)
      _total.push(total_bill[0].total_grand_total)
      if deliver_type.present? && deliver_type == 'Resource'
        _total.push(total_bill[0].total_pax)
        _total.push((total_bill[0].total_grand_total.to_f / total_bill[0].total_pax.to_f).round(2))
      else
        _total.push(total_bill[0].total_pax)
        _total.push((total_bill[0].total_grand_total.to_f / total_bill[0].total_pax.to_f).round(2))
      end  
      _total.push(settlement_data[:cash_sale])
      _total.push(settlement_data[:card_sale])
      _total.push(settlement_data[:loyalty_card_sale])
      _total.push(settlement_data[:third_party_sale])
      third_party_settlements.each do |key,value|
        _total.push(value) if _pref.include?(key)
      end
      csv<<_total
    end
  end

  def self.by_date_nc_to_csv(user_unit_id,unit_id,bills,from_datetime,to_datetime)
    CSV.generate do |csv|
      preferences = ReportPreference.by_unit(user_unit_id).by_key('nc_report_by_date').first
      _pref = preferences.present? ? JSON.parse(preferences.allowed_attributes) : ["bill_id","bill_serial","order_source","deliverables_at","status","user","remarks","date","procurement_cost","sales_price"]
      _pref_humanize =  _pref.map{|x| (x.humanize)}
      csv << _pref_humanize
      bills.each do |bill|
        _row = Array.new
        _row.push(bill.id) if _pref.include?('bill_id')
        _row.push(bill.serial_no) if _pref.include?('bill_serial')
        _row.push(bill.orders.first.source) if _pref.include?('order_source')
        if ['Address','Customer'].include?(bill.deliverable_type)
          _row.push(bill.deliverable_type) if _pref.include?('deliverables_at')
        else
          _order = bill.orders.first
          _row.push("#{_order.deliverable_type}: #{_order.deliverable.name} (##{_order.deliverable_id})") if _pref.include?('deliverables_at')
        end
        _row.push(bill.status) if _pref.include?('status')
        _row.push("#{bill.biller.profile.firstname} #{bill.biller.profile.lastname}") if _pref.include?('user')
        _row.push(bill.remarks) if _pref.include?('remarks')
        _row.push("#{bill.recorded_at.strftime('%d-%m-%Y, %I:%M %p')}") if _pref.include?('date')
        _row.push(bill.orders.inject(0){|result,order| result + order.order_details.where(:trash=>0).inject(0){|data,o_d| data+(o_d.procurement_cost*o_d.quantity)}}) if _pref.include?('procurement_cost')
        _row.push(bill.orders.inject(0){|result,order| result + order.order_details.where(:trash=>0).inject(0){|data,o_d| data+(o_d.unit_price_without_tax*o_d.quantity)}}) if _pref.include?('sales_price')
        csv << _row
      end
    end
  end
  # Data export to CSV

  def self.day_wise_tax_report_to_csv(user_unit_id,unit_id,dates,total_sale,from_datetime,to_datetime)
    _tax_grup_amount=tax_grup_amount(unit_id,dates)
    _tax_group_head=Array.new
    _tax_grup_amount.each do |tg|
      _tax_group_head.push(tg["tax_group_id"]) unless _tax_group_head.include?(tg["tax_group_id"])
    end
    CSV.generate do |csv|
      _row = Array.new
      _row.push("Date")
      _row.push("Total Taxable Amount")
      _tax_group_head.each do |tg_id| 
        TaxGroup.find(tg_id).tax_classes.each do |tc|
          _row.push(tc.name)
        end
        _row.push(TaxGroup.find(tg_id).name)
      end
      _row.push("Total Tax")
      _row.push("Total Invoice Value")
      csv << _row
      dates.each do |date|
        if date.to_date < "2016-04-01".to_date
          date = "2016-04-01" 
        end
        unit_detail_options=Unit.find(unit_id).unit_detail.options
        _from_datetime = date.to_date.beginning_of_day+unit_detail_options[:day_closing_time].to_i.hours if Unit.find(unit_id).unit_detail.present?
        _from_datetime ||= date.to_date.beginning_of_day
        _to_datetime = date.to_date.end_of_day+unit_detail_options[:day_closing_time].to_i.hours if Unit.find(unit_id).unit_detail.present?
        _to_datetime ||= date.to_date.end_of_day              
        _total_sale = Bill.unit_bills(unit_id).by_recorded_at(_from_datetime,_to_datetime).valid_bill.sum{|data| data.grand_total}
        _looprow = Array.new
        _looprow.push(date) 
        _looprow.push(unit_bills(unit_id).by_recorded_at(_from_datetime,_to_datetime).valid_bill.sum{|data| data.bill_amount}.round(2))
        _tax_group_head.each do |tg_id|
          _tax_group_amt=0
          _tax_grup_amount.each do |tg|
            if tg_id==tg["tax_group_id"]
              if tg["created_at"].to_date==date.to_date
                _tax_group_amt=tg["tax_group_amount"]
              end
            end
          end
          TaxGroup.find(tg_id).tax_classes.each do |tc|
            _looprow.push(tax_summery(unit_id,_from_datetime,_to_datetime,tc.name)[date])
          end
          _looprow.push(_tax_group_amt.round(2))
        end
        _looprow.push(unit_bills(unit_id).by_recorded_at(_from_datetime,_to_datetime).valid_bill.sum{|data| data.tax_amount}.round(2))
        _looprow.push(unit_bills(unit_id).by_recorded_at(_from_datetime,_to_datetime).valid_bill.sum{|data| data.grand_total}.round(2))
        csv << _looprow
      end
    end
  end

  def self.sales_summary_to_csv(user_unit_id,unit_id,dates,total_sale,from_datetime,to_datetime) # By Date Range
    @unit = Unit.find(unit_id)
    CSV.generate do |csv|
      _pref_humanize=[]

      @tax_persentage_group_amount=tax_persentage_group_amount(unit_id,dates)
      @tax_persentage_group_head=Array.new
      @tax_persentage_group_amount.each do |tg|
        if tg["tax_persentage_group"].to_f != 0
          @tax_persentage_group_head.push(tg["tax_persentage_group"]) unless @tax_persentage_group_head.include?(tg["tax_persentage_group"])
        end
      end

      preferences = ReportPreference.by_unit(user_unit_id).by_key('sales_report_by_date_range').first
      _pref = preferences.present? ? JSON.parse(preferences.allowed_attributes) : ["date","total_billed_amount","total_discount","total_nc","total_void","total_unpaid_amount","total_settled_amount","cash","card","loyalty_card","third_party","total_tax"]
    
      ############################# CSV HEADER ######################################
      if _pref.include?('date')
        _pref_humanize.push('Date')
      end
      if _pref.include?('bill_no')
        _pref_humanize.push('Bill No.')
      end
      if _pref.include?('bill_slno')
        _pref_humanize.push('Bill Sl.')
      end
      if _pref.include?('total_billed_amount')
        _pref_humanize.push('Total Billed Amount')
      end
      if _pref.include?('total_discount')
        _pref_humanize.push('Total Discount')
      end
      if _pref.include?('total_nc')
        _pref_humanize.push('Total NC')
      end
      if _pref.include?('total_nc')
        _pref_humanize.push('Total Void')
      end
      if _pref.include?('total_unpaid_amount')
        _pref_humanize.push('Total Unpaid Amount')
      end
      if _pref.include?('total_settled_amount')
        _pref_humanize.push('Total Settled Amount')
      end
      @tax_persentage_group_head.each do |tg_id| 
        _tax_class_persentage = tg_id/2
        _pref_humanize.push(tg_id.to_s+"% Taxable amount")
        Bill.report_attributes.each do |key, attributes|
          if key == "tax"
            attributes.each do |attribute|
              if _pref.include?(attribute.parameterize)
                _tax_class=TaxClass.find_by_name(attribute)
                if _tax_class.ammount == _tax_class_persentage && (_tax_class.tax_type=="variable" || _tax_class.tax_type=="simple")
                  _pref_humanize.push(attribute.humanize+"%") if _pref.include?('date')
                end
              end
            end
          end
        end
        _pref_humanize.push("Total #{tg_id}%") 
        _pref_humanize.push("Total With #{tg_id}%")
      end
      _pref_humanize.push("0 % Taxable Amount")
      _pref_humanize.push("Overall Taxable Amount")
      if _pref.include?('cash')
        _pref_humanize.push("Cash")
      end
      if _pref.include?('card')
        _pref_humanize.push("Card")
      end
      if _pref.include?('loyalty_card')
        _pref_humanize.push("Loyalty Card")
      end
      if _pref.include?('third_party')
        _pref_humanize.push("Third Party") 
      end       
      if _pref.include?('total_tax')
        _pref_humanize.push("Total Tax")
      end
      _unit = Unit.find(unit_id)
      _unit_detail_options = _unit.unit_detail.options if _unit.unit_detail.present?
      csv << _pref_humanize
      ################################ CSV HEADER END ##################################

      @unit_detail_options = @unit.unit_detail.options if @unit.unit_detail.present?
      total_value={}
      dates.each do |date|
        #_row = Array.new
        ############################### CSV VALUE ###################################
        if date.to_date < "2016-04-01".to_date
          date = "2016-04-01" 
        end
        _from_datetime = date.to_date.beginning_of_day+@unit_detail_options[:day_closing_time].to_i.hours if @unit.unit_detail.present?
        _from_datetime ||= date.to_date.beginning_of_day
        _to_datetime = date.to_date.end_of_day+@unit_detail_options[:day_closing_time].to_i.hours if @unit.unit_detail.present?
        _to_datetime ||= date.to_date.end_of_day              
        settlement_data = get_unit_settlement_data(unit_id,_from_datetime,_to_datetime)
        nc_void = invalid_bill.unit_bills(unit_id).by_recorded_at(from_datetime,to_datetime).group(:status).sum(:bill_amount)

        _total_sale = unit_bills(unit_id).by_recorded_at(_from_datetime,_to_datetime).valid_bill.sum{|data| data.grand_total}
        _day_bill = unit_bills(unit_id).by_recorded_at(_from_datetime,_to_datetime).valid_bill
        _row = Array.new
        _overall_taxable_amt = 0
        _total_non_0per_taxwith_amt = 0
        if _pref.include?('date')
          _row.push(date)
        end
        if _pref.include?('bill_no')
          _min_bill=_day_bill.map { |d| d[:id] }.min
          _max_bill=_day_bill.map { |d| d[:id] }.max
          _row.push( _min_bill.to_s+" - "+_max_bill.to_s)
        end
        if _pref.include?('bill_slno')
           _min_bill=_day_bill.map { |d| d[:id] }.min
           _max_bill=_day_bill.map { |d| d[:id] }.max
           _min_bill_sl=_min_bill.present? ? Bill.find(_min_bill).serial_no : ""
           _max_bill_sl=_max_bill.present? ? Bill.find(_max_bill).serial_no : ""
          _row.push( _min_bill_sl.to_s+"  "+_max_bill_sl.to_s)
        end
        if _pref.include?('total_billed_amount')
          _row.push(_total_sale)
          total_value["billed_amount"]=total_value["billed_amount"].present? ? (total_value["billed_amount"] + _total_sale) : _total_sale
        end
        if _pref.include?('total_discount')    
          _row.push(unit_bills(@unit_id).by_recorded_at(_from_datetime,_to_datetime).valid_bill.sum{|data| data.discount})
          total_value["discount"]=total_value["discount"].present? ? (total_value["discount"] + Bill.unit_bills(@unit_id).by_recorded_at(_from_datetime,_to_datetime).valid_bill.sum{|data| data.discount}) : Bill.unit_bills(@unit_id).by_recorded_at(_from_datetime,_to_datetime).valid_bill.sum{|data| data.discount}
        end
        if _pref.include?('total_nc') 
          if !nc_void['no_charge'].present?
            nc_void['no_charge'] = 0 
          end  
          _row.push((nc_void['no_charge'] || 0))
          total_value["total_nc"]=total_value["total_nc"].present? ? (total_value["total_nc"] + nc_void['no_charge'] || 0) : nc_void['no_charge'] || 0
        end
        if _pref.include?('total_void') 
          if !nc_void['void'].present?
            nc_void['void'] = 0
          end 
          _row.push((nc_void['void'] || 0))
          total_value["total_void"]=total_value["total_void"].present? ? (total_value["total_void"] + nc_void['void'] || 0) : nc_void['void'] || 0
        end
        if _pref.include?('total_unpaid_amount')  
          _row.push((_total_sale.to_f - settlement_data[:total_settlement].to_f))
           total_value["unpaid_amount"]=total_value["unpaid_amount"].present? ? (total_value["unpaid_amount"] + (_total_sale.to_f - settlement_data[:total_settlement].to_f)) : (_total_sale.to_f - settlement_data[:total_settlement].to_f)
        end
        if _pref.include?('total_settled_amount')
          _row.push(settlement_data[:total_settlement])
          total_value["settled_amount"]=total_value["settled_amount"].present? ? (total_value["settled_amount"] + settlement_data[:total_settlement]) : settlement_data[:total_settlement]
        end
        @tax_persentage_group_head.each do |tg_id|
          _tax_class_persentage = tg_id/2
          _tax_group_amt=0
          _tax_able_amt=0
          @tax_persentage_group_amount.each do |tg|
            if tg_id==tg["tax_persentage_group"]
              if tg["created_at"].to_date==date.to_date
                _tax_group_amt=tg["tax_amount"]
                _tax_able_amt=(_tax_group_amt*100)/tg_id
              end
            end
          end
          _row.push(_tax_able_amt)
          _overall_taxable_amt = _overall_taxable_amt + _tax_able_amt
          total_value["taxable_amount_#{tg_id}%"]=total_value["taxable_amount_#{tg_id}%"].present? ? ((total_value["taxable_amount_#{tg_id}%"] || 0) + _tax_able_amt) : _tax_able_amt
          report_attributes.each do |key, attributes|
            if key == "tax"
              attributes.each do |attribute|
                if _pref.include?(attribute.parameterize)
                  _tax_class=TaxClass.find_by_name(attribute)
                  if _tax_class.ammount == _tax_class_persentage && (_tax_class.tax_type=="variable" || _tax_class.tax_type=="simple")             
                    _row.push(tax_summery(unit_id,_from_datetime,_to_datetime,attribute)[date])
                    total_value["#{attribute.parameterize}%"]=total_value["#{attribute.parameterize}%"].present? ? ((total_value["#{attribute.parameterize}%"].to_f || 0 )+ (tax_summery(unit_id,_from_datetime,_to_datetime,attribute)[date].to_f || 0)) : (tax_summery(unit_id,_from_datetime,_to_datetime,attribute)[date].to_f || 0)
                  end
                end
              end
            end
          end
          _row.push(_tax_group_amt)
          total_value["total_#{tg_id}%"] = total_value["total_#{tg_id}%"].present? ? (total_value["total_#{tg_id}%"] + _tax_group_amt) : _tax_group_amt
          _row.push((_tax_group_amt+_tax_able_amt))
          _total_non_0per_taxwith_amt = _total_non_0per_taxwith_amt + (_tax_group_amt+_tax_able_amt)
          total_value["total_with_#{tg_id}%"] = total_value["total_with_#{tg_id}%"].present? ? ((total_value["total_with_#{tg_id}%"] || 0) + (_tax_group_amt+_tax_able_amt)) : (_tax_group_amt+_tax_able_amt)
        end
        _row.push(_total_non_0per_taxwith_amt)
        _overall_taxable_amt = _overall_taxable_amt + (_total_sale - _total_non_0per_taxwith_amt)
        _row.push(_overall_taxable_amt)
        if _pref.include?('cash') 
          _row.push(settlement_data[:cash_sale])
          total_value["cash"]=total_value["cash"].present? ? (total_value["cash"] + settlement_data[:cash_sale]) : settlement_data[:cash_sale]
        end
        if _pref.include?('card')                
          _row.push(settlement_data[:card_sale])
          total_value["card"]=total_value["card"].present? ? (total_value["card"] + settlement_data[:card_sale]) : settlement_data[:card_sale]
        end
        if _pref.include?('loyalty_card')                
          _row.push(settlement_data[:loyalty_card_sale])
          total_value["loyalty_card"]=total_value["loyalty_card"].present? ? (total_value["loyalty_card"] + settlement_data[:loyalty_card_sale]) : settlement_data[:loyalty_card_sale] 
        end
        if _pref.include?('third_party')                
          _row.push(settlement_data[:third_party_sale])
          total_value["third_party"]=total_value["third_party"].present? ? (total_value["third_party"] + settlement_data[:third_party_sale]) : settlement_data[:third_party_sale]  
        end
        if _pref.include?('total_tax')
          _row.push(unit_bills(unit_id).by_recorded_at(_from_datetime,_to_datetime).valid_bill.sum{|data| data.tax_amount})
          total_value["total_tax"]=total_value["total_tax"].present? ? (total_value["total_tax"] + unit_bills(unit_id).by_recorded_at(_from_datetime,_to_datetime).valid_bill.sum{|data| data.tax_amount}) : unit_bills(unit_id).by_recorded_at(_from_datetime,_to_datetime).valid_bill.sum{|data| data.tax_amount}
        end
        csv << _row
        ################################# CSV VALUE END #################################
      end
      _blank = Array.new
      _blank.push()
      csv<<_blank

      ################################### CSV FOOTER HEAD AND VALUE #############################
      _total = Array.new
      _total_val = Array.new
      _total.push("") if _pref.include?('date')
      _total_val.push("TOTAL") if _pref.include?('date')
      _total.push("") if _pref.include?('bill_no')
      _total_val.push("") if _pref.include?('bill_no')
      _total.push("") if _pref.include?('bill_slno')
      _total_val.push("") if _pref.include?('bill_slno')
      total_value.each do |key,val|
        _total.push(key.humanize)
        _total_val.push(val)
      end 
      csv<<_total  
      csv<<_total_val  
      ################################### CSV FOOTER HEAD AND VALUE END #############################

    end
  end

  def self.sale_user_wise_to_csv(sales)
    CSV.generate do |csv|
      _title = ["User", "Bill Amount(without Tax)", "Tax", "Discount", "Grand Total", "Date" ]
      csv << _title
      sales.each do |object|
        user = User.find(object.biller_id)
        _row = Array.new
        _row.push("#{user.profile.firstname} #{user.profile.lastname}")
        _row.push(object.total_bill_amount)
        _row.push(object.total_tax)
        _row.push(object.total_discount)
        _row.push(object.total_grand_total)
        _row.push(object.date)
        csv << _row
      end
    end
  end

  def self.boh_reports_to_csv(sales,report_type)
    if report_type != ""
      if report_type == "customer"
        CSV.generate do |csv|
          _title = ["Customer Name", "Customer Mobile", "Grand Total", "Total Paid Amount", "Boh Amount"]
          csv << _title
          _t_amt=0;
          _t_boh_amt=0;
          _t_paid_amt=0;
          sales.each do |object|
            _row = Array.new
            _row.push("#{object.customer.profile.firstname} #{object.customer.profile.lastname} ")
            _row.push(object.customer.mobile_no)
            _row.push(object.grand_total)
            _t_amt=_t_amt.to_f+object.grand_total.to_f
            _t_boh_amt=_t_boh_amt.to_f+object.boh_amount.to_f
            _t_paid_amt=_t_amt.to_f-_t_boh_amt.to_f
            _row.push(_t_paid_amt)
            _row.push(object.boh_amount)
            csv << _row
          end
          _blank = [""]
          csv << _blank
          _title2 = ["Total Bill Amount", "Total Boh Amount", "Total Paid Amount"]
          csv << _title2
          _row2 = Array.new
          _row2.push(_t_amt)
          _row2.push(_t_boh_amt)
          _t_paid_amt=_t_amt.to_f-_t_boh_amt.to_f
          _row2.push(_t_paid_amt)
          csv << _row2
        end
      elsif report_type == "bill"
        CSV.generate do |csv|
          _title = ["Bill Id","Bill Serial", "Grand Total","Paid Amount", "Boh Amount", "Biller", "Customer Name", "Customer Mobile", "Recorded Date", "Created Date"]
          csv << _title
          _t_amt=0;
          _t_boh_amt=0;
          sales.each do |object|
            _biller_name = "#{object.biller.profile.firstname.humanize} #{object.biller.profile.lastname.humanize}" if object.biller.present? and object.biller.profile.present?
            _biller_name ||= "#{object.biller.email}" if object.biller.present?
            _biller_name ||=""
            _row = Array.new
            _row.push(object.id)
            _row.push(object.serial_no)
            _row.push(object.grand_total)
            b_t_paid_amt=object.grand_total.to_f-object.boh_amount.to_f
            _t_amt=_t_amt.to_f+object.grand_total.to_f
            _row.push(b_t_paid_amt)
            _row.push(object.boh_amount)
            _t_boh_amt=_t_boh_amt.to_f+object.boh_amount.to_f
            _row.push("#{object.biller.profile.firstname} #{object.biller.profile.lastname}")
            _row.push("#{object.customer.profile.firstname} #{object.customer.profile.lastname} ")
            _row.push(object.customer.mobile_no)
            _row.push(object.recorded_at.strftime("%d-%m-%Y, %I:%M %p") )
            _row.push(object.created_at.strftime("%d-%m-%Y, %I:%M %p") )
            csv << _row
          end
          _blank = [""]
          csv << _blank
          _title2 = ["Total Bill Amount", "Total Boh Amount", "Total Paid Amount"]
          csv << _title2
          _row2 = Array.new
          _row2.push(_t_amt)
          _row2.push(_t_boh_amt)
          _t_paid_amt=_t_amt.to_f-_t_boh_amt.to_f
          _row2.push(_t_paid_amt)
          csv << _row2
        end
      end
    else
      CSV.generate do |csv|
        _title = ["Bill Id","Bill Serial", "Grand Total","Paid Amount", "Boh Amount", "Biller", "Customer Name", "Customer Mobile", "Recorded Date", "Created Date"]
        csv << _title
        _t_amt=0;
        _t_boh_amt=0;
        _t_paid_amt=0;
        sales.each do |object|
          _biller_name = "#{object.biller.profile.firstname.humanize} #{object.biller.profile.lastname.humanize}" if object.biller.present? and object.biller.profile.present?
          _biller_name ||= "#{object.biller.email}" if object.biller.present?
          _biller_name ||=""
          _row = Array.new
          _row.push(object.id)
          _row.push(object.serial_no)
          _row.push(object.grand_total)
          b_t_paid_amt=object.grand_total.to_f-object.boh_amount.to_f
          _t_amt=_t_amt.to_f+object.grand_total.to_f
          _row.push(b_t_paid_amt)
          _row.push(object.boh_amount)
          _t_boh_amt=_t_boh_amt.to_f+object.boh_amount.to_f
          _row.push("#{object.biller.profile.firstname} #{object.biller.profile.lastname}")
          _row.push("#{object.customer.profile.firstname} #{object.customer.profile.lastname} ")
          _row.push(object.customer.mobile_no)
          _row.push(object.recorded_at.strftime("%d-%m-%Y, %I:%M %p") )
          _row.push(object.created_at.strftime("%d-%m-%Y, %I:%M %p") )
          csv << _row
        end
        _blank = [""]
        csv << _blank
        _title2 = ["Total Bill Amount", "Total Boh Amount", "Total Paid Amount"]
        csv << _title2
        _row2 = Array.new
        _row2.push(_t_amt)
        _row2.push(_t_boh_amt)
        _t_paid_amt=_t_amt.to_f-_t_boh_amt.to_f
        _row2.push(_t_paid_amt)
        csv << _row2
      end
    end 
  end

  def self.cod_reports_to_csv(sales,report_type_cod)
    if report_type_cod != ""
      if report_type_cod == "customer"
        CSV.generate do |csv|
          _title = ["Customer Name", "Customer Mobile", "Grand Total"]
          csv << _title
          _t_amt=0;
          sales.each do |object|
            _row = Array.new
            _row.push("#{object.customer.profile.firstname} #{object.customer.profile.lastname} ")
            _row.push(object.customer.mobile_no)
            _row.push(object.grand_total)
            _t_amt=_t_amt.to_f+object.grand_total.to_f
            csv << _row
          end
          _blank = [""]
          csv << _blank
          _title2 = ["Total Bill Amount"]
          csv << _title2
          _row2 = Array.new
          _row2.push(_t_amt)
          csv << _row2
        end
      elsif report_type_cod == "bill"
        CSV.generate do |csv|
          _title = ["Bill Id","Bill Serial", "Grand Total", "Biller", "Customer Name", "Customer Mobile", "Date", "Created Date"]
          csv << _title
          _t_amt=0;
          sales.each do |object|
            _biller_name = "#{object.biller.profile.firstname.humanize} #{object.biller.profile.lastname.humanize}" if object.biller.present? and object.biller.profile.present?
            _biller_name ||= "#{object.biller.email}" if object.biller.present?
            _biller_name ||=""
            _row = Array.new
            _row.push(object.id)
            _row.push("#{object.prefix}""#{object.serial_no}""#{object.suffix}")
            _row.push(object.grand_total)
            _t_amt=_t_amt.to_f+object.grand_total.to_f
            _row.push("#{object.biller.profile.firstname} #{object.biller.profile.lastname}")
            _row.push("#{object.customer.profile.firstname} #{object.customer.profile.lastname} ")
            _row.push(object.customer.mobile_no)
            _row.push(object.recorded_at.strftime("%d-%m-%Y, %I:%M %p") )
            _row.push(object.created_at.strftime("%d-%m-%Y, %I:%M %p") )
            csv << _row
          end
          _blank = [""]
          csv << _blank
          _title2 = ["Total Bill Amount"]
          csv << _title2
          _row2 = Array.new
          _row2.push(_t_amt)
          csv << _row2
        end
      end
    else
      CSV.generate do |csv|
          _title = ["Bill Id","Bill Serial", "Grand Total", "Biller", "Customer Name", "Customer Mobile", "Date", "Created Date"]
          csv << _title
          _t_amt=0;
          sales.each do |object|
            _biller_name = "#{object.biller.profile.firstname.humanize} #{object.biller.profile.lastname.humanize}" if object.biller.present? and object.biller.profile.present?
            _biller_name ||= "#{object.biller.email}" if object.biller.present?
            _biller_name ||=""
            _row = Array.new
            _row.push(object.id)
            _row.push("#{object.prefix}""#{object.serial_no}""#{object.suffix}")
            _row.push(object.grand_total)
            _t_amt=_t_amt.to_f+object.grand_total.to_f
            _row.push("#{object.biller.profile.firstname} #{object.biller.profile.lastname}")
            _row.push("#{object.customer.profile.firstname} #{object.customer.profile.lastname} ")
            _row.push(object.customer.mobile_no)
            _row.push(object.recorded_at.strftime("%d-%m-%Y, %I:%M %p") )
            _row.push(object.created_at.strftime("%d-%m-%Y, %I:%M %p") )
            csv << _row
          end
          _blank = [""]
          csv << _blank
          _title2 = ["Total Bill Amount"]
          csv << _title2
          _row2 = Array.new
          _row2.push(_t_amt)
          csv << _row2
        end
    end        
  end

  def self.get_unit_third_party_settlement_data(unit_id,from_datetime,to_datetime)
    third_party_settlement_data = {}
    third_party_payment_options = ThirdPartyPayment.uniq.pluck(:third_party_payment_option_name)
    third_party_payment_options.each do |third_party_payment_option|
      third_party_settlement_data["#{third_party_payment_option}"]=ThirdPartyPayment.where(:id=>Bill.unit_bills(unit_id).valid_bill.by_recorded_at(from_datetime,to_datetime).joins(:payments).where(payments: { paymentmode_type: 'ThirdPartyPayment' }).pluck(:paymentmode_id) ,:third_party_payment_option_name => "#{third_party_payment_option}").sum(:amount)
    end 
    return third_party_settlement_data
  end

  def self.get_unit_coupon_settlement_data(unit_id,from_datetime,to_datetime)
    coupon_settlement_data = {}
    coupon_payment_options = CouponPayment.uniq.pluck(:name)
    coupon_payment_options.each do |coupon_payment_option|
      coupon_settlement_data["#{coupon_payment_option}"]=CouponPayment.where(:id=>Bill.unit_bills(unit_id).valid_bill.by_recorded_at(from_datetime,to_datetime).joins(:payments).where(payments: { paymentmode_type: 'CouponPayment' }).pluck(:paymentmode_id) ,:name => "#{coupon_payment_option}").sum(:amount)
    end 
    return coupon_settlement_data
  end

  private

  def apply_nc_void
    if self.void? || self.no_charge?
      self.grand_total = 0
      self.tax_amount = 0
      self.roundoff = 0
      self.bill_tax_amounts.destroy_all
      self.settlement.payments.map { |payment| payment.paymentmode.destroy } if self.settlement.present? and self.settlement.payments.present?
      self.settlement.payments.destroy_all if self.settlement.present? and self.settlement.payments.present?
      self.settlement.destroy if self.settlement.present?
    end
  end

  # => PUSH service for all subscribers
  def push_update_to_subscribers
    _subdomain = AppConfiguration.find_by_config_key('site_id')
    # Push notification for total sales in *PORTAL*
    _channels=Array.new
    _channels.push '/notifications/portal/subdomain/'+_subdomain.config_value.to_s+'/unit/'+self.unit_id.to_s+'/total_sales_today'
    _total_sales = Bill.unit_bills(self.unit_id).today.sum(:grand_total)
    _data_hash = {:total_sales_today => _total_sales}
    Notification.publish_in_faye(_channels,_data_hash)
    # Push notification for new order details *ANDROID*
    _channels = Array.new
    _channels.push '/notifications/android/subdomain/'+_subdomain.config_value.to_s+'/unit/'+self.unit_id.to_s+'/new_bill'
    _channels.push '/notifications/portal/subdomain/'+_subdomain.config_value.to_s+'/unit/'+self.unit_id.to_s+'/new_bill'
    Notification.publish_in_faye(_channels,{:bill => self})
  end 

  def send_email
    if AppConfiguration.get_config_value('send_customer_bill') == 'enabled'
      BillMailer.bill_details_mail_to_customer(self).deliver  if self.status == "paid" || self.status = "cod"
    end 
    if AppConfiguration.get_config_value('send_admin_bill') == 'enabled'
      BillMailer.bill_details_mail_to_admin(self).deliver if self.status == "paid" || self.status = "cod"
    end  
  end

  def send_sms    
    if AppConfiguration.get_config_value('send_customer_sms') == 'enabled'
      if self.status == "paid" || self.status = "cod"
        sms_sender_id = AppConfiguration.get_config('sms_sender_id') != '' ? AppConfiguration.get_config('sms_sender_id') : SenderID 
        unit_name = self.unit.unit_detail.options[:order_sms_unit_name].present? ? self.unit.unit_detail.options[:order_sms_unit_name] : self.unit.unit_name    
        bill_amount  = self.grand_total   
        _Currency = "Rs"    
        mobile_no = self.deliverable.customer.profile.contact_no if self.deliverable_type == "Address"  
        mobile_no = self.deliverable.profile.contact_no if self.deliverable_type == "Customer"    
        mobile_no ||= self.customer.profile.contact_no if self.customer_id.present?
        if mobile_no.present?   
          mobile_no = "91#{mobile_no}"    
          message   = 'Thank you for your order with us '+unit_name+'. Your Bill amount is '+_Currency+'.'+bill_amount.to_s+'. Please visit us again.'    
          message   = URI.encode(message)   
          uri = "http://#{API_BASE_URL}#{API_KEY}&MobileNo=#{mobile_no}&SenderID=#{sms_sender_id}&Message=#{message}&ServiceName=#{ServiceName}"   
          uri = URI.parse(uri)    
          rest_response = Net::HTTP.get_response(uri)   
          puts rest_response.body   
        end 
      end    
    end  
    if AppConfiguration.get_config_value('send_bill_details_to_customer') == 'enabled'
      if self.status == "paid" || self.status = "cod"
        sms_sender_id = AppConfiguration.get_config('sms_sender_id') != '' ? AppConfiguration.get_config('sms_sender_id') : SenderID  
        mobile_no = self.deliverable.customer.profile.contact_no if self.deliverable_type == "Address"  
        mobile_no = self.deliverable.profile.contact_no if self.deliverable_type == "Customer"    
        mobile_no ||= self.customer.profile.contact_no if self.customer_id.present?
        #mobile_no = '9674442296'
        #bill_header = self.unit.unit_detail.options[:bill_header_text].humanize
        #bill_footer = self.unit.unit_detail.options[:bill_footer_text].humanize
        unit_name = self.unit.unit_detail.options[:order_sms_unit_name].present? ? self.unit.unit_detail.options[:order_sms_unit_name] : self.unit.unit_name  
        bill_amount  = self.grand_total   
        _Currency = "Rs"
        bill_serial = self.serial_no
        barcode_numbers = ""
        paymentmode = "COD"
        self.orders.each do |_order|
          _order.order_details.each do |o_d|
            barcode_numbers = barcode_numbers + " " + o_d.product_unique_identity if o_d.product_unique_identity.present?
          end
        end
        barcode_numbers = "NA" if barcode_numbers == ""
        if self.settlement.present?
          self.settlement.payments.each do |payment|
            paymentmode = paymentmode + " " + payment.paymentmode_type
          end
        end  
        if mobile_no.present? 
          puts mobile_no
          mobile_no = "91#{mobile_no}"
          message = 'Welcome '+unit_name+', BILL NO:'+bill_serial+' BARCODE NUMBER:'+barcode_numbers+' GRAND TOTAL:'+_Currency+'.'+bill_amount.to_s+' PAYMENT MODE:'+paymentmode+' THANK YOU FOR SHOPPING, VISIT AGAIN N.B-NO EXCHANGE'
          message   = URI.encode(message)   
          uri = "http://#{API_BASE_URL}#{API_KEY}&MobileNo=#{mobile_no}&SenderID=#{sms_sender_id}&Message=#{message}&ServiceName=#{ServiceName}"   
          uri = URI.parse(uri)    
          rest_response = Net::HTTP.get_response(uri)   
          puts rest_response.body 
        end
      end  
    end  
    if AppConfiguration.get_config_value('send_admin_sms') == 'enabled'  
      if self.status == "paid" || self.status = "cod"
        sms_sender_id = AppConfiguration.get_config('sms_sender_id') != '' ? AppConfiguration.get_config('sms_sender_id') : SenderID
        unit_name = self.unit.unit_detail.options[:order_sms_unit_name].present? ? self.unit.unit_detail.options[:order_sms_unit_name] : self.unit.unit_name    
        bill_amount  = self.grand_total   
        _Currency = "Rs"    
        mobile_no = AppConfiguration.get_config('generate_admin_phone')   
        if mobile_no.present?   
          mobile_no = "91#{mobile_no}"    
          message   = 'Thank you for your order with us '+unit_name+'. Your Bill amount is '+_Currency+'.'+bill_amount.to_s+'. Please visit us again.'    
          message   = URI.encode(message)   
          uri = "http://#{API_BASE_URL}#{API_KEY}&MobileNo=#{mobile_no}&SenderID=#{sms_sender_id}&Message=#{message}&ServiceName=#{ServiceName}"   
          uri = URI.parse(uri)    
          rest_response = Net::HTTP.get_response(uri)   
          puts rest_response.body   
        end 
      end      
    end   
  end  
end

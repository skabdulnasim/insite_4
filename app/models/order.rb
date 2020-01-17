class Order < ActiveRecord::Base
  require "net/http"
  attr_accessible :order_status_id, :unit_id, :source, :order_sr_no, :deliverable_id, :serial_no,:consumer_type, :checksum,
                  :consumer_id,:delivery_boy_id, :trash, :cancel_cause, :deliverable_type, :device_id, :delivary_date, :resource_type,
                  :order_total_without_tax, :is_refandable, :total_tax, :total_discount, :order_subtotal, :is_stock_debited, :recorded_at, :customer_queue_id, :advance_payment, :delivery_charges, :section_id, :customer_id, :latitude, :longitude, :third_party_order_id, :address_id, :is_refund,
                  :order_details_attributes, :order_slots_attributes,:slot_id, :store_id, :has_proforma, :operation_type, :delivery_type, :reservation_id
  API_KEY       = 'Q2JRePQw7py'
  MobileNo      = '919933648398'
  SenderID      = 'YOTTOL'
  message       = 'Thank you for your order with Yottolabs, Kolkata. Your Order ID is # "#{self.id}". Please give us 30 min to serve you fresh and hot food.'
  Message       = URI.encode(message)
  ServiceName   = 'TEMPLATE_BASED'
  API_BASE_URL  = "smsapi.24x7sms.com/api_2.0/SendSMS.aspx?APIKEY="

  # Defining order sources
  _sources = %w(inhouse hungryleopard hlportal hlapp takeaway fos tsp)
  ThirdPartyPaymentOption.all.map{|pay| _sources.push(pay.name)} # Adding payment options in order source constant
  SOURCES = _sources.freeze

  ### =>  Model Relations
  belongs_to :deliverable, :polymorphic => true
  belongs_to :consumer, :polymorphic => true
  belongs_to :order_status
  belongs_to :unit
  belongs_to :customer_queue
  belongs_to :customer
  has_many :preauths, as: :advance
  has_and_belongs_to_many :quotations
  # has_one :external_order

  has_many :order_details, inverse_of: :order, :dependent => :delete_all
  has_many :bill_orders
  has_many :bills, through: :bill_orders
  has_many :stocks, as: :stock_transaction
  has_many :order_slots
  has_many :order_proformas
  has_many :proformas, through: :order_proformas
  belongs_to :store
  belongs_to :delivery_boy
  belongs_to :reservation
  has_many :order_status_logs

  accepts_nested_attributes_for :order_details, :reject_if => lambda { |a| a[:menu_product_id].blank? and a[:quantity].blank? }, allow_destroy: true
  accepts_nested_attributes_for :order_slots, allow_destroy: true

  ### => Model validations
  validates :source           , :presence => true
  validates :order_status_id  , :presence => true
  validates :unit             , :presence => true
  validates :deliverable      , :presence => true
  validates :consumer         , :presence => true
  validates :device_id        , :presence => true
  validates :trash            , :presence => true
  validates :billed           , :presence => true
  validates :delivary_date    , :presence => true
  validates :checksum, uniqueness: {message: I18n.t(:error_duplicate_checksum)}, :allow_blank => true, :allow_nil => true
  validate  :validate_order

  ### => Model Callbacks
  after_create :push_update_to_subscribers

  after_update :update_order_details_state, if: :order_status_id_changed?
  after_update :push_for_delivery_order, if: :order_status_id_changed?
                #:refund_to_paytm
  after_save  :save_order_status_log, if: :order_status_id_changed?

  before_create :checking_slot_availability, if: ->(o_s) {o_s.order_slots.present?}
  after_update :send_sms_to_customer_order_status_updated, if: :order_status_id_changed?            
  #after_update :push_update_to_subscribers_for_cancle_order, if: :trash_changed?
  after_update :external_order_status_updated, if: :order_status_id_changed?
  ### => Scopes
  scope :by_id_in,                      lambda {|ids|where(["id IN(?)", ids])}
  scope :check_store_id_in,             lambda {|store_ids|where(["store_id IN(?)", store_ids])}
  scope :check_deliverable_types, lambda {|deliverable_types|where(["deliverable_type IN(?)", deliverable_types])}
  scope :check_order_deliverable_id,    lambda {|deliverable_ids|where(["deliverable_id IN(?)", deliverable_ids])}
  scope :check_order_consumer_type,     lambda {|consumer_types|where(["consumer_type IN(?)", consumer_types.capitalize])}
  scope :order_by_delivery_boy_id,      lambda {|delivery_boy_id|where(["delivery_boy_id =(?)", delivery_boy_id])}
  scope :check_avlty_delivery_boy,      lambda {|delivery_boy_id|where(['order_status_id < (?) and delivery_boy_id = (?) and date(delivary_date) = (?)', 5, delivery_boy_id, Date.today])}
  scope :check_order_consumer_id,       lambda {|consumer_ids|where(["consumer_id IN(?)", consumer_ids.capitalize])}
  scope :check_order_status,            lambda {|order_status_ids|where(["order_status_id IN(?)", order_status_ids])}
  scope :check_order_source,            lambda {|order_sources|where(["source IN(?)", order_sources])}
  scope :check_order_billed,            lambda {|billed|where(["billed IN(?)", billed])}
  scope :check_order_unit,              lambda {|current_unit|where(["unit_id =(?)", current_unit])}
  scope :order_canceled,                lambda {where(["trash =(?)", 1])}
  scope :orders_by_unit_in_date,        lambda {|unit|where(['unit_id = (?) and deliverable_type = (?) and delivary_date >= now() and order_status_id NOT IN (?) and delivery_boy_id IS NULL ', unit, 'Address', [OrderStatus.get_status("delivered").id, OrderStatus.get_status("New").id]])}
  scope :orders_by_unit,                lambda {|unit|where(['unit_id = (?) and deliverable_type = (?) and order_status_id NOT IN (?) and delivery_boy_id IS NULL ', unit, 'Address', [OrderStatus.get_status("delivered").id, OrderStatus.get_status("New").id]])}
  scope :orders_assigned_delivery_boy,  lambda {|delivery_boy_id|where(['deliverable_type = (?) and delivery_boy_id = (?) and order_status_id NOT IN (?)', 'Address', delivery_boy_id, [OrderStatus.get_status("delivered").id]])}
  scope :inhouse_order,                 lambda { where(["source = ?",'inhouse']) }
  scope :not_canceled,                  lambda {where(["trash !=(?)", 1])}
  scope :not_billed,                    lambda {where("billed !=?", 1)}
  scope :not_future,                    lambda {where("order_status_id !=?", 8)}
  scope :billed?,                       lambda {where("billed =?", 1)}
  scope :Preparing?,                    lambda {where("order_status_id =(?)" , OrderStatus.get_status("Preparing").id)}
  scope :Delivered?,                    lambda {where("order_status_id =(?)" , OrderStatus.get_status("Delivered").id)}
  scope :Approved?,                     lambda {where("order_status_id =(?)" , OrderStatus.get_status("Approved").id)}
  scope :Prepared?,                     lambda {where("order_status_id =(?)" , OrderStatus.get_status("Prepared").id)}
  scope :Picked?,                       lambda {where("order_status_id =(?)" , OrderStatus.get_status("Picked").id)}
  scope :today,                         lambda {where("DATE(delivary_date) =?", Date.today)}
  scope :desc,                          lambda { order('delivary_date DESC') }
  scope :New?,                          lambda {where("order_status_id =(?)" , OrderStatus.get_status("New").id)}
  scope :asc,                           lambda { order('delivary_date ASC') }
  scope :last_day,                      lambda { where(["orders.created_at > ?",Time.zone.now.beginning_of_day]) }
  scope :last_week,                     lambda { where(["orders.created_at > ?",7.day.ago.beginning_of_day]) }
  scope :last_month,                    lambda { where(["orders.created_at > ?",30.day.ago.beginning_of_day]) }
  scope :set_unit_in,                   lambda {|unit_ids|where(["unit_id in (?)", unit_ids])}
  scope :set_order_id_in,               lambda {|order_ids|where(["id in (?)", order_ids])}
  scope :orders_after_id,               lambda {|id|where(["id > ?", id])}
  scope :by_billed_status,              lambda {|billed|where(["billed = ?", billed])}
  scope :by_trash,                      lambda {|trash|where(["trash =(?)", trash])}
  scope :by_unit_id,                    lambda {|unit_id|where(["unit_id =(?)", unit_id])}
  scope :by_status,                     lambda {|status|where(["order_status_id =(?)", status])}
  scope :by_source,                     lambda {|source|where(["source =(?)", source])}
  scope :by_deliverable_type,           lambda {|deliverable_type| where(["deliverable_type =(?)", deliverable_type.capitalize]) }
  scope :by_deliverable_id,             lambda {|deliverable_id| where(["deliverable_id =(?)", deliverable_id]) }
  scope :by_consumer_type,              lambda {|consumer_type| where(["consumer_type =(?)", consumer_type]) }
  scope :by_consumer_id,                lambda {|consumer_id| where(["consumer_id =(?)", consumer_id]) }
  scope :by_date_range,                 lambda {|from_date, upto_date|where('created_at BETWEEN ? AND ?',from_date,upto_date)}
  scope :order_by_date,                 lambda {|from_date, upto_date|where('date(created_at) BETWEEN ? AND ?',from_date,upto_date)}
  scope :not_asign_orders,              lambda {where(:delivery_boy_id => nil)}
  scope :set_id,                        lambda {|id|where(["orders.id=?", id])}
  scope :by_user_login,                 lambda {|login| where("(deliverable_id = ?  AND deliverable_type = 'Customer') OR  (deliverable_id IN (?)  AND deliverable_type = 'Address' )",Customer.by_identification(login).first,Customer.by_identification(login).first.addresses.pluck(:id))}
  scope :order_by_date,                 lambda {|from_date, upto_date|where('date(created_at) BETWEEN ? AND ?',from_date,upto_date)}
  scope :by_recorded_at,                lambda {|from_date, upto_date|where('recorded_at BETWEEN ? AND ?',from_date,upto_date)}
  scope :by_stock_issue,                lambda {|status|where(["orders.is_stock_debited=?", status])}
  scope :by_resource_type,              lambda {|resource_type|where(["resource_type=?", resource_type])}
  scope :by_delivery_date,              lambda {|delivary_date|where(["date(delivary_date)=?", delivary_date])}
  scope :by_customer_queue,             lambda {|customer_queue_id| where(["customer_queue_id = ?",customer_queue_id])}
  scope :upto_delivery_date,            lambda {|delivary_date|where(["date(delivary_date) BETWEEN ? AND ?", Date.today, delivary_date])}
  scope :resource_orders,               lambda { |resource_id| where(["deliverable_id = ?  AND deliverable_type = 'Resource'",resource_id])}
  scope :set_resources,                 lambda { |resource_ids| where(["deliverable_id in (?)  AND deliverable_type = 'Resource'",resource_ids])}
  scope :by_customer,                   lambda { |customer| where("customer_id = ?",customer)}
  scope :by_delivery_date_range,        lambda {|from_date, upto_date|where('date(delivary_date) BETWEEN ? AND ?',from_date,upto_date)}
  scope :set_store_id_in,               lambda {|store_ids|where(["store_id in (?)", store_ids])}
  scope :by_operation_type,             lambda { |operation_type| where("operation_type = ?",operation_type)}
  scope :by_has_proforma,               lambda {|has_proforma| where("has_proforma=?",has_proforma)}
  scope :set_store_id,                  lambda {|store_id|where(["orders.store_id=?", store_id])}
  scope :external?,                     lambda {where("orders.id IN( SELECT order_id FROM external_orders)")}
  scope :reservation_orders,            lambda {|reservation_id|where(["orders.reservation_id=?", reservation_id])}
  def initialize(attributes=nil, *args)
    super
    if new_record?
      # set default values for new records only
      initialized = (attributes || {}).stringify_keys
      if !initialized.key?('billed')
        self.billed = 0
      end
      if !initialized.key?('trash')
        self.trash = 0
      end
      if !initialized.key?('order_status_id')
        self.order_status_id = 2
      end
      if !initialized.key?('delivary_date')
        self.delivary_date = Time.now.utc
      else
        self.delivary_date = self.delivary_date.utc
      end
      if !initialized.key?('recorded_at')
        self.recorded_at = Time.now.utc
      else
        self.recorded_at = self.recorded_at.utc
      end
      if initialized.key?('deliverable_type')
        self.deliverable_type = self.deliverable_type.camelize
      end
      if initialized.key?('deliverable_id')
        if self.deliverable_id > 6000000
          self.deliverable_id = 497
        end
      end
      if initialized.key?('consumer_type')
        self.consumer_type = self.consumer_type.camelize
      end
      if !initialized.key?('delivery_charges')
        self.delivery_charges = 0
      end
      if initialized.key?('consumer_id')
        if self.consumer_id == 0
          self.consumer_id = 3
        end  
      end
      if !initialized.key?('has_proforma')
        self.has_proforma = 0
      end
      self.section_id = self.order_details.first.section_id
    end
  end

  # Custom validation for order
  def validate_order
    if new_record?
      ensure_ordering_enabled
      ensure_order_items_present
      ensure_order_items_in_stock if inventory_enabled?
      if check_lot_stock_enabled?
        ensure_item_in_retail_menu if retail_menu_enabled?
      end  
    end
  end

  # Checking stock status of every order items
  def ensure_order_items_in_stock stock_of_items={:items_in_stock => Array.new, :insufficient_items => Array.new, :insufficient_ingredients => Array.new, :insufficient_customizations => Array.new}
    return if offline_order_enabled? # Stock check is not required while saving orders placed in offline mode.
    return unless should_check_stock?
    self.order_details.each do |object|
      object.has_valid_stock? if object.is_uniquely_identifiable_item? and object.lot_id.nil?# Check if the product unique identity is valid or not
      object.has_valid_lot_stock? if object.is_uniquely_identifiable_item? and object.lot_id.present?
      locked_quantity = ((stock_on_hold object.menu_item_product_id, self.unit_id, object.product_unique_identity, object.lot_id) + object.quantity)
      object.item_or_its_ingredients_in_stock? object.menu_product.product, object.menu_item_store_id, locked_quantity, stock_of_items, object.product_unique_identity
    end
    if stock_of_items[:insufficient_items].present? or stock_of_items[:insufficient_ingredients].present? or stock_of_items[:insufficient_customizations].present?
      errors.add(:base, I18n.t(:error_insufficient_stock, items: stock_of_items[:insufficient_items].uniq.join(', '), ingredients: stock_of_items[:insufficient_ingredients].uniq.join(', '), customizations: stock_of_items[:insufficient_customizations].uniq.join(', ')))
    end
  end

  # Checking stock status of every order items
  def ensure_item_in_retail_menu stock_of_items={:items_in_stock => Array.new, :insufficient_items => Array.new, :insufficient_ingredients => Array.new, :insufficient_customizations => Array.new}
    #return unless should_check_stock?
    self.order_details.each do |object|
      object.has_valid_stock? if object.is_uniquely_identifiable_item? and object.lot_id.nil?# Check if the product unique identity is valid or not
      object.has_valid_lot_stock? if object.is_uniquely_identifiable_item? and object.lot_id.present?
      locked_quantity = ((stock_on_hold object.menu_item_product_id, self.unit_id, object.product_unique_identity, object.lot_id) + object.quantity)
      object.item_or_its_ingredients_in_stock? object.menu_product.product, object.menu_item_store_id, locked_quantity, stock_of_items, object.product_unique_identity
    end
    if stock_of_items[:insufficient_items].present? or stock_of_items[:insufficient_ingredients].present? or stock_of_items[:insufficient_customizations].present?
      errors.add(:base, I18n.t(:error_insufficient_stock, items: stock_of_items[:insufficient_items].uniq.join(', '), ingredients: stock_of_items[:insufficient_ingredients].uniq.join(', '), customizations: stock_of_items[:insufficient_customizations].uniq.join(', ')))
    end
  end

  # Total Order item quantity where stock not debited
  def stock_on_hold product_id, unit_id, product_unique_identity, lot_id
    item_quantity = 0
    cust_quantity = 0
    if product_unique_identity.nil?
      item_quantity = OrderDetail.set_unit(unit_id).by_product(product_id).stock_not_debited.sum :quantity
      cust_quantity = OrderDetailCombination.set_unit(unit_id).by_product(product_id).stock_not_debited.sum :combination_qty
    elsif product_unique_identity.present? and lot_id.nil?
      item_quantity = OrderDetail.set_unit(unit_id).by_product(product_id).by_unique_identity(product_unique_identity).stock_not_debited.sum :quantity
      cust_quantity = OrderDetailCombination.set_unit(unit_id).by_product(product_id).by_unique_identity(product_unique_identity).stock_not_debited.sum :combination_qty
    elsif product_unique_identity.present? and lot_id.present?
      item_quantity = OrderDetail.set_unit(unit_id).by_product(product_id).by_unique_identity(product_unique_identity).by_lot_id(lot_id).stock_not_debited.sum :quantity
      #cust_quantity = OrderDetailCombination.set_unit(unit_id).by_product(product_id).by_unique_identity(product_unique_identity).stock_not_debited.sum :combination_qty
    end
    return (item_quantity + cust_quantity)
  end

  # Check configuration if ordering is enabled
  def ensure_ordering_enabled
    if ordering_disabled?
      errors.add(:base, I18n.t(:error_ordering_disabled))
    end
  end

  # Check if order items are present or not
  def ensure_order_items_present
    unless self.order_details.present?
      errors.add(:base, I18n.t(:error_there_are_no_items_for_this_order))
    end
  end

  # Return true if ordering is disabled
  def ordering_disabled?
    AppConfiguration.get_config_value('accept_new_order') == 'disabled'
  end

  # Return true if inventory module is disabled
  def inventory_enabled?
    AppConfiguration.get_config_value('inventory_module') == 'enabled'
  end

  # Return true if offline ordering is enabled
  def offline_order_enabled?
    AppConfiguration.get_config_value('offline_order') == 'enabled'
  end

  # Return true if Retail menu is enabled
  def retail_menu_enabled?
    AppConfiguration.get_config_value('retail_menu') == 'enabled'
  end

  # Return true if Retail menu is enabled
  def check_lot_stock_enabled?
    AppConfiguration.get_config_value('ckeck_lot_stock') == 'enabled'
  end

  # Return true if stock check while ordering is enabled
  def should_check_stock?
    AppConfiguration.get_config_value('stock_check_on_order') == 'enabled'
  end

  # Return true if stock check of raw items is enabled
  def should_check_ingredient_stock?
    AppConfiguration.get_config_value('check_raw_product_stock') == 'enabled'
  end

  def reload_stock_issue_status
    is_stock_debited = items_whose_stock_not_issued_yet.present? ? false : true
    update_attribute(:is_stock_debited, is_stock_debited)
  end

  def items_whose_stock_not_issued_yet
    self.order_details.map{|item| item if item.stock_not_issued_yet? }.compact
  end

  def self.most_sold_items
    Order.joins(:order_details).select("sum(order_details.quantity) as quantity, order_details.menu_product_id").group("order_details.menu_product_id").order("quantity DESC")
  end

  def self.send_sms
    uri = "http://#{API_BASE_URL}#{API_KEY}&MobileNo=#{MobileNo}&SenderID=#{SenderID}&Message=#{Message}&ServiceName=#{ServiceName}"
    rest_response = RestClient.get uri
  end

  def billed?
    return (billed == 1) ? true : false
  end

  # Generate error message for menu product item s
  def self.generate_order_error_msg(product, order_quantity, current_stock)
    insufficients_products_arr ={}
    insufficients_products_arr[:error] = "Your order has been canceled. #{order_quantity} #{product.name} is insufficient."
    insufficients_products_arr[:product_name] = product.name
    insufficients_products_arr[:product_id] = product.id
    insufficients_products_arr[:current_stock] = current_stock
    return insufficients_products_arr
  end

  # Generate error message for product item or for combination items
  def self.generate_order_error_msg_customise(product,order_quantity,current_stock)
    insufficients_products_arr ={}
    insufficients_products_arr[:error] = "Your order has been canceled. #{order_quantity} #{product.name} is insufficient."
    insufficients_products_arr[:product_name] = product.name
    insufficients_products_arr[:product_id] = product.id
    insufficients_products_arr[:current_stock] = current_stock
    return insufficients_products_arr
  end

  # Generate error message for raw product item
  def self.generate_order_error_msg_raw(product,order_quantity,current_stock)
    insufficients_products_arr ={}
    insufficients_products_arr[:error] = "Your order has been canceled. As #{order_quantity} #{product.basic_unit} raw product #{product.name} is insufficient in stock."
    insufficients_products_arr[:product_name] = product.name
    insufficients_products_arr[:product_id] = product.id
    insufficients_products_arr[:current_stock] = current_stock
    return insufficients_products_arr
  end

  def self.check_order_deliverable_types(order_deliverable_types)
    if !order_deliverable_types.empty?
      delivery_types = Array.new
      delivery_type_ids = Array.new
      order_deliverable_types.each do |order_deliverable_type|
        order_deliverable_type_arr = order_deliverable_type.split(",").map {|i| i.to_s}
        delivery_types.push order_deliverable_type_arr[0]
        delivery_type_ids.push order_deliverable_type_arr[1]
      end
      where('deliverable_type IN(?) AND deliverable_id IN(?)',delivery_types,delivery_type_ids)
    else
      all
    end
  end

  def self.save_assign_order(data)
    parsed_json = JSON.parse(data)
    parsed_json.each do |delivery_boy_id, orders_array|
      if orders_array.any?
        orders_array.each do |order_id|
          @order = Order.find(order_id)
          @order = @order.update_attribute(:delivery_boy_id, delivery_boy_id)
        end
      end
    end

    return @order
  end
  def self.cancel_assigned_order(data)
    parsed_json = JSON.parse(data)
    parsed_json.each do |delivery_boy_id, orders_array|
      if orders_array.any?
        orders_array.each do |order_id|
          @order = Order.find(order_id)
          @order = @order.update_attribute(:delivery_boy_id, nil)
        end
      end
    end
    return @order
  end

  def self.order_by_lat_lon(unit_id, latitude, longitude, delivery_boy_id)
    address  = Address.where("latitude::text = (?) AND longitude::text = (?)",latitude.to_s,longitude.to_s).first
    if address.present?
      if delivery_boy_id.present?
        orders   = address.orders.orders_assigned_delivery_boy(delivery_boy_id).select('id').select('delivary_date').select('order_status_id')
      else
        orders   = address.orders.orders_by_unit(unit_id).select('id').select('delivary_date').select('order_status_id')
      end
      orders_array = []
      orders.each do |order|
        orders_array.push('id' => order.id, 'delivary_date' => order.delivary_date, 'status' => order.order_status.name, 'color_code' => order.order_status.color_code)
      end
      return orders_array
    end
  end

  def self.swap_deliverable(order_object, deliverable_type, deliverable_id)
    if deliverable_type.present? and deliverable_id.present? and Object.const_get(deliverable_type.capitalize).find(deliverable_id).present?
      order_object.update_attributes(:deliverable_type => deliverable_type.capitalize, :deliverable_id => deliverable_id)
    end
  end

  def  self.update_order_price(order_id)
    order = Order.find(order_id)
    _order_total_without_tax, _total_tax,_total_discount, _order_subtotal = 0,0,0,0
    order.order_details.each do |odt|
      if odt.trash == 0
        
        if AppConfiguration.get_config_value('discount_on_item') == 'enabled'
          _order_total_without_tax += odt.unit_price_without_tax * odt.quantity
          _total_tax += odt.tax_amount * odt.quantity
        else  
          _order_total_without_tax += (odt.unit_price_without_tax * odt.quantity)
          _total_tax += odt.tax_amount * odt.quantity
        end
        _total_discount += (odt.discount)
        _order_subtotal += (odt.subtotal)
      end
    end
    order.update_attributes(:order_total_without_tax => _order_total_without_tax, :total_tax => _total_tax, :total_discount =>_total_discount, :order_subtotal => _order_subtotal)
  end

  # def  self.update_order_price_for_return(order_id)
  #   order = Order.find(order_id)
  #   _order_total_without_tax, _total_tax,_total_discount, _order_subtotal = 0,0,0,0
  #   order.order_details.each do |odt|
  #     _order_total_without_tax += (odt.unit_price_without_tax * (odt.quantity - odt.return_qty))
  #     _total_tax += (odt.tax_amount * (odt.quantity - odt.return_qty))
  #     _total_discount += (odt.discount)
  #     _order_subtotal += (_order_total_without_tax + _total_tax)
  #   end
  #   order.update_attributes(:order_total_without_tax => _order_total_without_tax, :total_tax => _total_tax, :total_discount =>_total_discount, :order_subtotal => _order_subtotal)
  # end

  def self.update_order_for_is_stock_debited(order_id)
    is_stock_debited = Array.new
    order = Order.find(order_id)
    order.order_details.map { |item| 
      is_stock_debited.push item if item.is_stock_debited =='no' 
      }
    if is_stock_debited.count == 0 
      order.update_attribute(:is_stock_debited, true) 
    else 
      order.update_attribute(:is_stock_debited, false)
    end
  end

  def update_order_trash
    canceled_order_array, oreder_array = Array.new, Array.new
    self.order_details.map { |e|
      oreder_array.push e
      canceled_order_array.push e if e.trash==1
      }
    if canceled_order_array.count == oreder_array.count then self.cancel! else self.undo_cancel! end       
  end

  def cancel!
    #_orders = Order.by_deliverable_id(self.deliverable_id).by_deliverable_type("Resource").not_canceled.not_billed
    update_attribute(:trash, 1)
    if self.deliverable_type=='Table'
       Table.update_table_state(1,self.unit_id,self.deliverable_id,self.consumer_id,self.device_id)
    end
    if self.deliverable_type=='Resource'
       Resource.update_resource_state(1,self.unit_id,self.deliverable_id,self.consumer_id,self.device_id)
    end 
  end

  def undo_cancel!
    #_orders = Order.by_deliverable_id(self.deliverable_id).by_deliverable_type("Resource").not_canceled.not_billed
    update_attribute(:trash, 0)
    if self.deliverable_type=='Table'
       Table.update_table_state(2,self.unit_id,self.deliverable_id,self.consumer_id,self.device_id)
    end
    if self.deliverable_type=='Resource'
       Resource.update_resource_state(2,self.unit_id,self.deliverable_id,self.consumer_id,self.device_id)
    end
  end

  def bill
    bills.first
  end

  def push_update_to_subscribers_for_approve
    if self.order_status_id != 8
      _subdomain = AppConfiguration.find_by_config_key('site_id')
      # Push notification for total order count in *PORTAL*
      _channels = Array.new
      time = Time.zone.now.beginning_of_day
      today_orders = OrderManagement::order_no_by_date(time, self.unit_id)
      _channels.push '/notifications/portal/subdomain/'+_subdomain.config_value.to_s+'/unit/'+self.unit_id.to_s+'/total_orders_today'
      Notification.publish_in_faye(_channels,{:total_orders_today => today_orders})

      # Push notification for new order details *ANDROID*
      _channels = Array.new
      _channels.push '/notifications/android/subdomain/'+_subdomain.config_value.to_s+'/unit/'+self.unit_id.to_s+'/new_order'
      _channels.push '/notifications/portal/subdomain/'+_subdomain.config_value.to_s+'/unit/'+self.unit_id.to_s+'/new_order'
      Notification.publish_in_faye(_channels,{:order => self})
    end  
  end

  def self.update_deliverable(reservation)
    _orders = Order.by_customer_queue(reservation.customer_queue_id)
    _orders.each do |order|
      order.update_attributes(:deliverable_id => "#{reservation.resource_id}", :deliverable_type => 'Resource', :resource_type => "#{reservation.resource.resource_type.name}", :order_status_id => 2)
    end
  end

  def generate_deliverable_otp
    self.deliverable_otp = rand(000000..999999).to_s.rjust(6, "0")
    save
  end

  def send_deliverable_otp
    if AppConfiguration.get_config_value('send_delivery_confirmation') == 'enabled'
      if self.customer.mobile_no.present?
        sms_sender_id = AppConfiguration.get_config('sms_sender_id') != '' ? AppConfiguration.get_config('sms_sender_id') : SenderID
        unit_name=self.unit.unit_name
        mobile_no = self.customer.mobile_no
        otp=self.deliverable_otp
        #message='Thank you for ordering with '+unit_name+'. Your deliverable pin is '+otp.to_s+'.'
        message = 'Thank you for ordering with '+unit_name+'. Your deliverable pin is '+otp.to_s+', for order '+self.id.to_s+'.'
        message = URI.encode(message)
        uri = "http://#{API_BASE_URL}#{API_KEY}&MobileNo=#{mobile_no}&SenderID=#{sms_sender_id}&Message=#{message}&ServiceName=#{ServiceName}"
        uri = URI.parse(uri)    
        rest_response = Net::HTTP.get_response(uri)
      else
        puts "phone number is  missing"
      end
    end
  end
  def checking_slot_availability
    _order_slot = self.order_slots.first
    _slot = Slot.find(_order_slot.slot_id)
    _order_placed = OrderSlot.by_slot(_slot.id).by_delivery_date(_order_slot.delivery_date).count
    _max_booking = _slot.max_booking
    _order_availability = _max_booking - _order_placed
    raise "Maximum order reached for #{_slot.title} slot on #{_order_slot.delivery_date}" if _order_availability <= 0
  end


  private

  def save_order_status_log
    _order_status_log = OrderStatusLog.new
    _order_status_log[:unit_id] = self.unit_id
    _order_status_log[:user_id] = self.consumer_id
    _order_status_log[:order_status_id] = self.order_status_id
    _order_status_log[:order_status_name] = OrderStatus.find(self.order_status_id).name
    _order_status_log[:order_id] = self.id
    _order_status_log.save
  end

  def push_update_to_subscribers
    if self.order_status_id != 8 && self.order_status_id != 11
      _subdomain = AppConfiguration.find_by_config_key('site_id')
      # Push notification for total order count in *PORTAL*
      _channels = Array.new
      time = Time.zone.now.beginning_of_day
      today_orders = OrderManagement::order_no_by_date(time, self.unit_id)
      _channels.push '/notifications/portal/subdomain/'+_subdomain.config_value.to_s+'/unit/'+self.unit_id.to_s+'/total_orders_today'
      Notification.publish_in_faye(_channels,{:total_orders_today => today_orders})

      # Push notification for new order details *ANDROID*
      _channels = Array.new
      _channels.push '/notifications/android/subdomain/'+_subdomain.config_value.to_s+'/unit/'+self.unit_id.to_s+'/new_order'
      _channels.push '/notifications/portal/subdomain/'+_subdomain.config_value.to_s+'/unit/'+self.unit_id.to_s+'/new_order'
      Notification.publish_in_faye(_channels,{:order => self})
      _channels = Array.new
      _channels.push '/notifications/android/subdomain/'+_subdomain.config_value.to_s+'/unit/'+self.unit_id.to_s+'/new_push_order'
      _return_arr = Array.new
      _order_arr = {}
      _order_arr[:order_id] = self.id
      _order_arr[:order_sr_no]  = self.order_sr_no
      _order_arr[:order_status_id] = self.order_status_id
      _order_arr[:order_subtotal] = self.order_subtotal
      _order_arr[:order_time] = self.created_at.strftime("%I:%M %P")
      _order_arr[:delivery_time] = self.delivary_date.strftime("%d-%m-%Y, %I:%M %p")      
      _order_arr[:source] = self.source
      _order_arr[:deliverable_id] = self.deliverable_id
      _order_arr[:deliverable_type] = self.deliverable_type
      _order_arr[:approved_orders] = self.order_details.where('status=?',"approved").count
      _order_arr[:preparing_orders] = self.order_details.where('status=?',"preparing").count
      _order_arr[:prepared_orders] = self.order_details.where('status=?',"prepared").count
      if self.deliverable_type == "Section"
        _order_arr[:waiter_id] = self.consumer.id
        _order_arr[:waiter_name] = "#{self.consumer.profile.firstname}" "#{self.consumer.profile.lastname}"
      elsif self.deliverable_type == "Resource"
        _order_arr[:table_id] = self.deliverable.id
        _order_arr[:table_name] = self.deliverable.name
        _order_arr[:table_status] = self.deliverable.status
        _order_arr[:waiter_id] = self.consumer.id
        _order_arr[:waiter_name] = "#{self.consumer.profile.firstname}" "#{self.consumer.profile.lastname}"
      end  
      _order_details_array = Array.new
      self.order_details.each do |od|
        _arr={}
        _arr[:product_id] = od.product_id
        _arr[:product_name] = od.product_name
        _arr[:status] = od.status
        _arr[:quantity] = od.quantity
        _arr[:order_item_time] = od.created_at.strftime("%I:%M %P")
        _arr[:sort_id] = od.sort_id
        _arr[:item_preference] = od.item_preference
        if self.deliverable_type == "Table"
          _arr[:source] = "table"
        else
          _arr[:source] = "non-table"
        end
        _arr[:order_details_id] = od.id
        _order_details_array.push(_arr)
      end  
      _order_arr['order_details'] = _order_details_array
      Notification.publish_in_faye(_channels,{:order => _order_arr})
    end  
  end

  def push_for_delivery_order
    if self.order_status_id == 6
      _subdomain = AppConfiguration.find_by_config_key('site_id')
      _channels = Array.new
      _channels.push '/notifications/android/subdomain/'+_subdomain.config_value.to_s+'/unit/'+self.unit_id.to_s+'/order_deliver'
      Notification.publish_in_faye(_channels,{:order => self})
    end  
  end

  def send_sms
    if AppConfiguration.get_config_value('send_confirm_sms') == 'enabled'
      sms_sender_id = AppConfiguration.get_config('sms_sender_id') != '' ? AppConfiguration.get_config('sms_sender_id') : SenderID
      unit_name = self.unit.unit_detail.options[:order_sms_unit_name].present? ? self.unit.unit_detail.options[:order_sms_unit_name] : self.unit.unit_name
      order_id  = self.id
      mobile_no = self.deliverable.profile.contact_no
      mobile_no = "91#{mobile_no}"
      message   = 'Thank you for your order with Us, '+unit_name+'. Your Order ID is # '+order_id.to_s+'. Please give us 30 min to serve you fresh and hot food.'
      message   = URI.encode(message)
      uri = "http://#{API_BASE_URL}#{API_KEY}&MobileNo=#{mobile_no}&SenderID=#{sms_sender_id}&Message=#{message}&ServiceName=#{ServiceName}"
      uri = URI.parse(uri)
      rest_response = Net::HTTP.get_response(uri)
      puts rest_response.body
    end
  end

  
  def refund_to_paytm
    if self.is_refandable.present? && self.is_refandable == 'yes' && self.trash == 1
      if self.bill.settlement.present?
        self.bill.settlement.payments.each do |payment|
          if payment['paymentmode_type'] == "PaytmPayment"
            paramList = Hash.new
            paramList["MID"] = payment.paymentmode.MID
            paramList["REFID"] = "#{request.subdomain}""#{self.id}"
            paramList["TXNID"] = payment.paymentmode.TXNID
            paramList["ORDERID"] = payment.paymentmode.ORDERID
            paramList["REFUNDAMOUNT"] = payment.paymentmode.TXNAMOUNT
            paramList["TXNTYPE"] = "REFUND"
            @paytm_keys = PaytmSecurity.first
            @paramList = paramList
            @checksum = refund_generate_checksum()
            @checksum = URI::encode(@checksum)
            uri = URI('https://securegw-stage.paytm.in/refund/HANDLER_INTERNAL/REFUND')
            http = Net::HTTP.new(uri.host, uri.port)
            req = Net::HTTP::Post.new(uri.path, {'Content-Type' =>'application/json'})
            req.body = {"MID" => payment.paymentmode.MID, "ORDERID" => payment.paymentmode.ORDERID, "TXNID" => payment.paymentmode.TXNID, "TXNTYPE" => "REFUND", "REFUNDAMOUNT" => payment.paymentmode.TXNAMOUNT, "REFID"=> "#{request.subdomain}""#{self.id}", "CHECKSUM" => @checksum}.to_json
            http.use_ssl = (uri.scheme == "https")
            @res = http.request(req)
            @res = JSON.parse(@res.body)
          end
        end
      end
    end  
  end

  def external_order_status_updated
    @ext_order = ExternalOrder.find_by_order_id(self.id)
    if @ext_order.present? && @ext_order.order_source == "zomato"
      if self.order_status_id == 2
        @status_parm={}
        @status_parm["order_id"] = @ext_order.external_order_id
        @status_parm["external_order_id"] = self.id
        @status_parm["delivery_time"] = 200
        @status_response=ThirdpartyZomato.thirdparty_zomato_status_confirm(@status_parm.to_json)
      elsif self.order_status_id == 5
        @status_parm={}
        @status_parm["order_id"] = @ext_order.external_order_id
        @status_response=ThirdpartyZomato.thirdparty_zomato_status_confirm(@status_parm.to_json)
      elsif self.order_status_id == 6
        @status_parm={}
        @status_parm["order_id"] = @ext_order.external_order_id
        @status_response=ThirdpartyZomato.thirdparty_zomato_status_confirm(@status_parm.to_json)
      end       
    end
  end

  def send_sms_to_customer_order_status_updated
    unit_name = self.unit.unit_detail.options[:order_sms_unit_name].present? ? self.unit.unit_detail.options[:order_sms_unit_name] : self.unit.unit_name
    order_status = self.order_status.name
    #self.order_details.map{|item| item.update_column(:status, order_status)}
    self.order_details.map { |item| item.update_statesss(order_status)}
    if AppConfiguration.get_config_value('send_sms_on_status_change') == 'enabled'
      sms_sender_id = AppConfiguration.get_config('sms_sender_id') != '' ? AppConfiguration.get_config('sms_sender_id') : SenderID
      order_id  = self.id
      mobile_no = self.deliverable.customer.profile.contact_no if self.deliverable_type == "Address"  
      mobile_no = self.deliverable.profile.contact_no if self.deliverable_type == "Customer"    
      mobile_no ||= self.customer.profile.contact_no if self.customer_id.present?
      #mobile_no = '9674442296'
      mobile_no = "91#{mobile_no}"
      OrderStatus.all.each do |status|
        if status.name == order_status
          if order_status == "picked"
            if AppConfiguration.get_config_value("send_sms_for_order_status_#{order_status}") == "enabled"
              if self.delivery_boy_id.present?
                delivery_boy = DeliveryBoy.find(self.delivery_boy_id)
                message   = 'Your order '+order_id.to_s+' has been picked up by our delivery executive '+delivery_boy.name+' and is on the way.'
                message   = URI.encode(message)
                uri = "http://#{API_BASE_URL}#{API_KEY}&MobileNo=#{mobile_no}&SenderID=#{sms_sender_id}&Message=#{message}&ServiceName=#{ServiceName}"
                uri = URI.parse(uri)
                rest_response = Net::HTTP.get_response(uri)
                puts rest_response.body 
              end 
            end 
          elsif order_status == "approved" || order_status == "prepared" || order_status == "canceled" || order_status == "deivered" || order_status == "preparing"
            if AppConfiguration.get_config_value("send_sms_for_order_status_#{order_status}") == "enabled"
              if order_status == "preparing"
                message = 'Your order '+order_id.to_s+' is '+ order_status+ '.'
              elsif order_status == "deivered"
                message = 'Your order '+order_id.to_s+' has been '+ order_status+ '. Thanks for using '+ unit_name
              else
                message = 'Your order '+order_id.to_s+' has been '+ order_status+ '.'
              end
              message = URI.encode(message)
              uri = "http://#{API_BASE_URL}#{API_KEY}&MobileNo=#{mobile_no}&SenderID=#{sms_sender_id}&Message=#{message}&ServiceName=#{ServiceName}"
              uri = URI.parse(uri)
              rest_response = Net::HTTP.get_response(uri)
              puts rest_response.body 
            end    
          end   
        end  
      end 
    end
  end

  def update_order_details_state
    if AppConfiguration.get_config_value('third_party_urbanpiper') == "enabled" 
      @ext_order = ExternalOrder.find_by_order_id(self.id)
      if @ext_order.present?
        if @ext_order.order_source == "urban_piper"
          @status_hash={}
          if self.trash == 1
            @status_hash["new_status"] = "Cancelled"
            @status_hash["message"] = self.cancel_cause.present? ? self.cancel_cause : "Cancelled"
          else
            if self.order_status_id == 1
              @status_hash["new_status"] = "Acknowledged"
              @status_hash["message"] = "Acknowledged"
            elsif self.order_status_id == 2
              @status_hash["new_status"] = "Acknowledged"
              @status_hash["message"] = "Acknowledged"
            elsif self.order_status_id == 3
              @status_hash["new_status"] = "Confirmed"
              @status_hash["message"] = "Confirmed" 
            elsif self.order_status_id == 4
              @status_hash["new_status"] = "Food Ready"
              @status_hash["message"] = "Food Ready"
            elsif self.order_status_id == 5
              @status_hash["new_status"] = "Dispatched"
              @status_hash["message"] = "Dispatched"
            elsif self.order_status_id == 6 || self.order_status_id == 7
              @status_hash["new_status"] = "Completed"
              @status_hash["message"] = "Completed"  
            end
          end
          ThirdpartyUrbanpiper.thirdparty_urbanpiper_order_status(@ext_order.external_order_id,@status_hash.to_json)
        end 
      end
    end
  end

  def push_update_to_subscribers_for_cancle_order
    _order_arr = {}
    _order_arr[:order_id] = self.id
    _order_arr[:trash] = self.trash
    _order_details_array = Array.new
    self.order_details.each do |od|
      _arr={}
      _arr[:sort_id] = od.sort_id
      _arr[:order_details_id] = od.id
      _arr[:trash] = od.trash
      _order_details_array.push(_arr)
    end 
    _order_arr['order_details'] = _order_details_array
    _subdomain = AppConfiguration.find_by_config_key('site_id')
    # Push notification for new order details *ANDROID*
    _channels = Array.new
    _channels.push '/notifications/android/subdomain/'+_subdomain.config_value.to_s+'/unit/'+self.unit_id.to_s+'/order_cancle'
    Notification.publish_in_faye(_channels,{:order => _order_arr})
  end

  def self.refund_money _order, _account_no = '', _ifsc_code = ''
    if _order.is_refandable.present? && _order.is_refandable == 'yes' && _order.trash == 1
      amount = _order.order_subtotal
      _cancelation_policy = _order.unit.cancelation_policy
      cancelation_charge = 0
      if _cancelation_policy.present?
        if _cancelation_policy.cancelation_charge_type.present? && _cancelation_policy.cancelation_charge.present?
          cancelation_charge = _cancelation_policy.cancelation_charge_type == 'percentage' ? (amount * _cancelation_policy.cancelation_charge.to_f)/100 : _cancelation_policy.cancelation_charge.to_f
        end
      end
      amount = amount - cancelation_charge
      MoneyRefund.create(:customer_id => _order.customer_id, :order_id => _order.id, :refund_amount => amount, :account_no => _account_no, :ifsc_code => _ifsc_code)
    end
  end

end

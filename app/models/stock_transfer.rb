class StockTransfer < ActiveRecord::Base
  attr_accessible :transfer_type, :transfer_status, :product_tokens, :production_product_tokens, :activity_id, :primary_store_id, :secondary_store_id,
                  :status, :status_log, :vehicle_id, :store_requisition_log_id, :expected_delivery_date, :boxing_id, :stock_transfer_meta_attributes

  attr_reader :transfer_type, :transfer_status, :product_tokens, :production_product_tokens

  TRANSFER_TYPES = %w(to_other_store to_production_store to_own_store to_waste_bin)
  TRANSFER_STATUSES = %w(incomplete ready_for_shipment shipped delivering shipment_returned delivering_return_shipment delivered)

  # => Defining relations
  belongs_to :from_store, :class_name => "Store", :foreign_key => "primary_store_id"
  belongs_to :to_store, :class_name => "Store", :foreign_key => "secondary_store_id"
  belongs_to :store_requisition_log
  belongs_to :vehicle
  has_one :stock_transfer_invoice
  has_one :stock_transfer_template
  has_many :stocks, as: :stock_transaction
  has_many :stock_transfer_meta
  has_many :products, through: :stock_transfer_meta
  has_many :kitchen_production_audits
  has_many :production_audits, :class_name => "KitchenProductionAudit", :foreign_key => "stock_transfer_id"


  accepts_nested_attributes_for :stock_transfer_meta, allow_destroy: true, update_only: true

  after_save :debit_stock_from_inventory, if: :transfer_in_state_to_debit_stock?
  after_save :credit_stock_to_inventory, if: :transfer_in_state_to_credit_stock?
  after_save :create_notification, if: :transfer_in_state_to_credit_stock?
  after_save :issue_production_audit, if: :should_initiate_production_audit?
  after_save :push_update_to_subscribers

  # => Model validations
  validates :activity_id, :presence => true
  validates :primary_store_id, :presence => true
  validates :secondary_store_id, :presence => true
  validate :validate_transfer

  # => Scopes
  scope :desc_order, lambda { order("created_at desc") }
  scope :pickup_pending, lambda { where(:status => '10') }
  scope :shipped, lambda { where(:status => '20'..'60') }
  scope :delivering, lambda { where(:status => '30') }
  scope :return_delivering, lambda { where(:status => '60') }
  scope :delivered, lambda { where(:status => '100') }
  scope :set_transfer_status, lambda {|status_id|where(["status=?", status_id])}
  scope :kitchen_not_received, lambda { where(:status => '1') }
  scope :set_status_in, lambda{|status| where(["status in (?)", status])}
  scope :valid, lambda { where(["status != ?", '0']) }
  scope :by_date_range, lambda {|from_date, upto_date|where('stock_transfers.updated_at BETWEEN ? AND ?',from_date,upto_date)}

  def product_tokens=(ids)
    self.product_ids = ids.split(',').uniq{|id| id}
  end

  def production_product_tokens=(ids)
    self.production_product_ids = ids.split(',').uniq{|id| id}
  end

  def transfer_type=(type)
    if type == 'to_other_store' || type == 'to_waste_bin'
      self.activity_id = 2
    elsif type == 'to_production_store'
      self.activity_id = 3
    elsif type == 'to_own_store'
      self.activity_id = 4
    end
  end

  def transfer_status=(status)
    case status
    when 'incomplete'
      self.status = '0'
    when 'delivering_in_production_center'
      self.status = '1'
    when 'quick_delivering'
      self.status = '5'
    when 'ready_for_shipment'
      self.status = '10'
    when 'shipped'
      self.status = '20'
    when 'delivering'
      self.status = '30'
    when 'shipment_returned'
      self.status = '50'
    when 'delivering_return_shipment'
      self.status = '60'
    when 'return_shipment_delivered'
      self.status = '90'
    when 'delivered'
      self.status = '100'
    end
  end

  def validate_transfer
    if should_initiate_transfer?
      ensure_transfer_items_in_stock if AppConfiguration.get_config_value('stock_identity') != 'enabled'
    end
  end

  def ensure_transfer_items_in_stock stock_of_items={:insufficient_items => Array.new}
    self.stock_transfer_meta.each do |object|
      object.item_in_stock? stock_of_items, self.primary_store_id
    end
    if stock_of_items[:insufficient_items].present?
      errors.add(:base, I18n.t(:error_insufficient_stock_for_transfer, items: stock_of_items[:insufficient_items].uniq.join(', ')))
    end
  end

  def debit_stock_from_inventory
    self.stock_transfer_meta.map { |e| e.issue_stock }
  end

  def credit_stock_to_inventory
    self.stock_transfer_meta.map{ |e|
      e.update_attributes(:price_without_tax => e.price_without_tax/e.quantity_transfered*e.quantity_received)
    }
    self.stock_transfer_meta.map { |e| e.credit_stock }
  end

  def create_notification
    notification_flag = 0;
    self.stock_transfer_meta.map{ |e| 
      notification_flag = 1 if e.quantity_transfered != e.quantity_received
      e.update_attributes(:status => "partially_receved") if e.quantity_transfered != e.quantity_received
    }
    Notification.new_notification("partially stock received","partially stock received by #{self.to_store.name}",'inventory',"/stores/#{self.primary_store_id}/stock_transfers/#{self.id}",self.from_store.unit_id,nil,'high') if notification_flag == 1
  end

  def issue_production_audit
    self.stock_transfer_meta.map { |e| e.initiate_production_audit }
  end

  def transfer_in_state_to_debit_stock?
    return false unless should_initiate_transfer?
    return true
  end

  def transfer_in_state_to_credit_stock?
    return false unless should_finish_transfer?
    return true
  end

  def should_initiate_production_audit?
    should_finish_transfer?
  end

  def should_initiate_transfer?
    state = (self.status=='1' or self.status=='5' or self.status=='10' or self.status=='30') ? true : false
  end

  def should_finish_transfer?
    if activity_id == 2
      return (status == '100' or status == '90') ? true : false
    elsif activity_id == 3
      # return (status == '2') ? true : false
      return (status == '2' or status == '100') ? true : false
    elsif activity_id == 4
      # return (status == '6') ? true : false
      return (status == '6' or status == '100') ? true : false
    else
      return false
    end
  end

  def get_status_to_initiate_transfer
    status = '10'
    if self.activity_id == 2
      if self.vehicle_id.present?
        status = '10'
      else
        status = '30'
      end
    elsif activity_id == 3
      status = '1'
    elsif activity_id == 4
      status = '5'
    end
    status
  end

  def transfer_is_incomplete?
    (self.status == '1') ? true : false
  end

  def add_item_for_transfer product_id, quantity
    item = self.stock_transfer_meta.find_or_initialize_by_product_id(product_id)
    item_quantity = item.quantity_transfered.present? ? (item.quantity_transfered + quantity) : quantity
    item[:quantity_transfered] = item_quantity
    item.save
  end

  # --------------------
  #Initiate Transfer
  def self.initiate_transfer(_primary_store,_secondary_store,_vehicle_id,_activity_id,_status,_status_log,_requisition_id,_expected_date)
    _new_transfer = StockTransfer.new
    _new_transfer[:primary_store_id] = _primary_store
    _new_transfer[:secondary_store_id] = _secondary_store
    _new_transfer[:vehicle_id] = _vehicle_id
    _new_transfer[:activity_id] = _activity_id
    _new_transfer[:status] = _status
    _new_transfer[:status_log] = _status_log
    _new_transfer[:store_requisition_log_id] = _requisition_id
    _new_transfer[:expected_delivery_date] = _expected_date
    _new_transfer.save
    return _new_transfer
  end

  #Generate Status JSON
  def self.generate_status_json(_transfer_id,_status_id,_status_desc,_current_user)
    if !_transfer_id.nil?
      _transfer = StockTransfer.find(_transfer_id)
      _json_status = JSON.parse(_transfer.status_log)
    else
      _json_status = {}
    end
    _current_time = Time.now.strftime("%d-%m-%Y %H:%M")
    _arr = {}
    _arr[:status_id] = _status_id
    _arr[:status_description] = _status_desc
    _arr[:time] = _current_time
    _arr[:user_id] = _current_user
    _json_status[_status_id]=_arr
    _status_log_json = JSON.generate(_json_status)
    return _status_log_json
  end

  def self.by_date(from_date, upto_date)
    if from_date.present? && upto_date.present?
      where('created_at BETWEEN ? AND ?',from_date,upto_date)
    else
      all
    end
  end

  def self.set_transfer(received_stocks,stock_transaction_id,user_id)
    received_products = received_stocks
    stock_transfer = StockTransfer.find(stock_transaction_id)
    @status_log = StockTransfer.generate_status_json(stock_transfer.id,'100','Shipment items have been received successfully (App)',user_id)
    @store = Store.find(stock_transfer.secondary_store_id)
    received_products.each do |stk|
      _stock_details = Stock.set_transaction(stock_transfer.id).get_product(stk['product_id']).first
      _recvd_stock = Stock.save_stock(stk['product_id'],stock_transfer.secondary_store_id,_stock_details.price,stk['recv_stock'],stock_transfer.id,'stock_transfer',stk['recv_stock'],0,nil,nil,nil)
    end
    stock_transfer.update_attribute(:status,'100')
    stock_transfer.update_attribute(:status_log,@status_log)
    return stock_transfer
  end

  def self.to_csv(transfers)
    CSV.generate do |csv|
      csv << ["Transfer ID", "Reference", "Products", "Total Amount", "To Store", "Date"]
      transfers.each do |object|
        _products = "#{object.stocks.type_debit.map{|stock| stock.product.name + stock.stock_debit.to_s + stock.product.basic_unit}.join(" | ")}"
        _ref = object.store_requisition_log_id.present? ? "Requisition ID: #{object.store_requisition_log_id}" : ""
        csv << ["#{object.id}", "#{_ref}", "#{_products}", "#{object.stocks.set_store(object.primary_store_id).sum(:price)}","#{object.to_store.name} (Branch: #{object.to_store.unit.unit_name})", "#{object.created_at.strftime('%d-%^b-%Y, %I:%M %p')}"]
      end
    end
  end
  def push_update_to_subscribers
    if self.vehicle_id.present?
      if self.status == "10" || self.status == "20" || self.status == "100"
        _subdomain = AppConfiguration.find_by_config_key('site_id')
        _channels = Array.new
        _channels.push '/notifications/android/subdomain/'+_subdomain.config_value.to_s+'/unit/'+self.from_store.unit_id.to_s+'/new_transfer'
        _return_arr = Array.new
        _pd_arr = {}
        _pd_arr[:stock_transaction_id] = self.id
        _pd_arr[:date] = self.created_at
        _pd_arr[:status] = self.status
        _pd_arr[:vehicle_id] = self.vehicle_id
        _pd_arr[:vehicle_name] = self.vehicle.name
        _pd_arr['from_store'] = self.from_store
        _pd_arr['to_store'] = self.to_store
        _pro_array = Array.new
        self.stock_transfer_meta.each do |meta_attribute|
          _arr={}
          _arr[:serial_no] = meta_attribute.id
          _arr[:product_id] = meta_attribute.product_id
          _arr[:product_name] = meta_attribute.product.name
          _arr[:product_unit] = meta_attribute.product.basic_unit
          _arr[:product_amount] = meta_attribute.quantity_transfered
          _arr[:product_image] = meta_attribute.product.product_image
          _pro_array.push(_arr)
        end  
        _pd_arr['products'] = _pro_array
        Notification.publish_in_faye(_channels,{:stock_transfer => _pd_arr})
      end  
    end  
  end
  def self.po_transfer_and_receive_reports_to_csv(stock_transfers, from_store, to_store, from_date, to_date)
    CSV.generate do |csv|
      _pref = ["Product Name","Stock transfer amount", "Transfer from", "Stock received amount", "Receive to", "Back to store", "from date", "to date"]
      _pref_humanize = _pref.map{|x| (x.humanize)}
      csv << _pref_humanize
      stock_transfers.each do |st|
        st.stock_transfer_meta.each do |stm|
          _row = Array.new
          _product = Product.find(stm.product_id)
          _row.push(_product.package_component.present? ?  _product.product_name(_product) : _product.name)
          _basic_unit = stm.product.basic_unit
          _row.push("#{stm.quantity_transfered}#{_basic_unit}")
          _from_store = Store.find(from_store)
          _row.push(_from_store.name)
          _row.push("#{stm.quantity_received}#{_basic_unit}")
          _to_store = Store.find(to_store)
          _row.push(_to_store.name)
          _row.push("#{stm.quantity_transfered - stm.quantity_received}#{_basic_unit}")
          _row.push(from_date)
          _row.push(to_date)
          _row.push
          csv << _row
        end
      end
    end
  end

end

class StoreRequisitionLog < ActiveRecord::Base
  attr_accessible :from_store_id, :product_count, :sent_product_count, :sent_product_details, :status, :store_id, :store_requisition_id, :expected_received_date
  
  # => Defining relations
  belongs_to :store_requisition
  belongs_to :store
  belongs_to :from_store, :class_name => "Store", :foreign_key => "from_store_id"
  has_many :stock_transfers


  # => Setting purchase attributes before_validation
  before_validation :set_requisition_log_attributes

  # => Model valications
  validates :from_store_id, :presence => true
  validates :store_id, :presence =>true
  validates :store_requisition_id, :presence =>true

  # => Scopes
  scope :na_requisitions, lambda { where(:status => '1') }
  scope :desc_order, lambda { order("created_at desc") }
  scope :store_requistion, lambda {|store_id|where(["store_id=?", store_id])}
  scope :by_created_at,   lambda {|rq_date|where("date(created_at) =(?)" ,rq_date)}
  scope :by_unit, lambda {|unit_id| joins(:store_requisition).merge(StoreRequisition.by_unit(unit_id))}
  scope :by_status, lambda {|status| where(["status=?", status])}
  scope :by_from_store_id, lambda {|from_store_id| where(["from_store_id=?", from_store_id])}
  scope :set_status_in, lambda{|status| where(["status in (?)", status])}

  def self.by_date(from_date, upto_date)
    if from_date.present? && upto_date.present?
      where('created_at BETWEEN ? AND ?',from_date,upto_date)
    else
      all
    end    
  end

  def self.to_csv(requisitions)
    CSV.generate do |csv|
      csv << ["Requisition ID", "Reference", "Products", "From Store", "Status", "Date"]
      requisitions.each do |object|
        _products = "#{object.store_requisition.store_requisition_metum.map{|meta| meta.product.name + meta.product_ammount.to_s + meta.product.basic_unit}.join(" | ")}" 
        _status = self.get_requisition_status object
        csv << ["#{object.id}", "#{object.store_requisition.name} (ID: #{object.store_requisition_id})", "#{_products}", "#{object.from_store.name} (Branch: #{object.from_store.unit.unit_name})", "#{_status}", "#{object.created_at.strftime('%d-%^b-%Y, %I:%M %p')}"]
      end
    end
  end

  def self.get_requisition_status object
    _status=""
    if object.status == "1"
      _status = "Rew"
    elsif object.status == "2"
     _status = "Rejected"
    elsif object.status == "3"
     _status = "Approved"
    elsif object.status == "4"
     _status = "Stock Issued"
    end
    return _status
  end  

  def self.update_log(_product_id,_log_id,_total_qty)
    _log = StoreRequisitionLog.find(_log_id)
    if _log.sent_product_details.nil?
      _sent_status = {}
      _log.sent_product_count = 0
    else
      _sent_status = JSON.parse(_log.sent_product_details)
    end
    _sent_status[_product_id]=_total_qty  
    _new_status = JSON.generate(_sent_status) 
    _log.update_attribute(:sent_product_details, _new_status)
    _log.update_attribute(:sent_product_count, (_log.sent_product_count + 1))
    _new_log = StoreRequisitionLog.find(_log_id)
    if _log.product_count == _new_log.sent_product_count
      _log.update_attribute(:status, "4") #All product transfer complete
    end
  end

  private
  # => Callback function to set model attributes before validation 
  def set_requisition_log_attributes
    _rq_details = StoreRequisition.find(self.store_requisition_id)
    self.status = "1"
    self.store_id = _rq_details.to_store
    self.from_store_id = _rq_details.store_id
    self.product_count = _rq_details.store_requisition_metum.count
  end  
end

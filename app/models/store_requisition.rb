class StoreRequisition < ActiveRecord::Base
  has_many :store_stocks
  has_many :store_requisition_logs
  has_many :store_requisition_metum, :class_name => "StoreRequisitionMetum", :foreign_key => "requisition_id", :dependent => :destroy
  belongs_to :store
  belongs_to :from_store, :class_name => "Store", :foreign_key => "store_id"
  belongs_to :destination_store, :class_name => "Store", :foreign_key => "to_store_id"
  #has_many :store_requisition_meta, :class_name => 'StoreRequisitionMetum', :foreign_key => 'requisition_id'
  scope :by_user_id, lambda{|user_id|where(["user_id=?", user_id])}
  scope :by_date_range, lambda{|from_date,to_date|where(["date(created_at) BETWEEN ? AND ?", from_date,to_date])}
  def initialize(attributes=nil, *args)
    super
    if new_record?
      # set default values for new records only
      initialized = (attributes || {}).stringify_keys
      if initialized.key?('to_store')
        self.to_store_id = self.to_store
      end
    end
  end
  accepts_nested_attributes_for :store_requisition_metum, :reject_if => lambda { |a| a[:product_id].blank? }, :allow_destroy => true

  attr_accessible :name, :requisition_type, :valid_from, :valid_till, :mode, :store_id, :to_store, :unit_id, :description, :requisition_code, :user_id, :business_type, :to_store_id, :latitude, :longitude
 
  # Model scope
  scope :unit_requistion,          lambda {|store_id|where(["to_store=?", store_id])}
  scope :by_unit, lambda{|unit_id| where(["unit_id=?", unit_id])}
end

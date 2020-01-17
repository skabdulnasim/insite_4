class ResourceOrderHistory < ActiveRecord::Base
  attr_accessible :latitude, :longitude, :recorded_at, :resource_id, :unit_id, :user_id, :device_id, :resource_order_history_details_attributes

  validates :resource_id, :presence => true
  validates :unit_id, :presence => true
  validates :user_id, :presence => true
  validates :device_id, :presence => true

  belongs_to :resource
  belongs_to :unit
  belongs_to :user
  has_many :resource_order_history_details

  accepts_nested_attributes_for :resource_order_history_details, :reject_if => lambda { |a| a[:menu_product_id].blank? and a[:quantity].blank? }, allow_destroy: true

  def initialize(attributes=nil, *args)
    super
    if new_record?
      # set default values for new records only
      initialized = (attributes || {}).stringify_keys
      if !initialized.key?('recorded_at')
        self.recorded_at = Time.now.utc
      else
        self.recorded_at = self.recorded_at.utc
      end
    end
  end

  #Model Scope
  scope :by_unit,             lambda {|unit_id|where(["unit_id=?", unit_id])}
  scope :by_resource,         lambda {|resource_id|where(["resource_id=?", resource_id])}
  scope :by_user,             lambda {|user_id|where(["user_id=?", user_id])}
end

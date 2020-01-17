class VendorContract < ActiveRecord::Base
  attr_accessible :latitude, :longitude, :unit_id, :vendor_id, :visited_by, :total_contract_price, :grand_total, :total_tax_amount, :recorded_at, :vendor_product_prices_attributes

  # Model Relations
  has_many :vendor_product_prices
  belongs_to :vendor
  belongs_to :unit
  # Model Validation
  validates :vendor, :presence => true
  validates :unit, :presence => true

  accepts_nested_attributes_for :vendor_product_prices, allow_destroy: true

  def initialize(attributes=nil, *args)
    super
    if new_record?
      initialized = (attributes || {}).stringify_keys 
      if !initialized.key?('recorded_at')
        self.recorded_at = Time.now.utc
      else
        self.recorded_at = self.recorded_at.utc
      end
    end
  end
  
end
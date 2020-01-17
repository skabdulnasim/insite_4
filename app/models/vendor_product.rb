class VendorProduct < ActiveRecord::Base
	belongs_to :product
	belongs_to :vendor
	has_many :vendor_product_prices
  belongs_to :tax_group
	attr_accessible :price, :product_id, :vendor_id, :tax_group_id, :recorded_at
	# validates :product_id, :presence => true
	# validates :vendor_id,  :presence => true
	
  scope :by_product,  lambda {|product_id|where(["product_id = ?", product_id])}
  scope :by_vendor,  lambda {|vendor_id|where(["vendor_id = ?", vendor_id])}
	scope :by_vendor_product_in, lambda {|product_ids|where(["product_id in(?)",product_ids])}
	scope :by_vendor_product, lambda {|product_id,vendor_id|where(["product_id=(?) AND vendor_id=(?)",product_id,vendor_id])}
	scope :set_vendor_id_in,  lambda {|vendor_ids|where(["vendor_id in (?)", vendor_ids])}
  scope :set_product_id_in,  lambda {|product_ids|where(["product_id in (?)", product_ids])}

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
  
	def self.filter_by_product(vendor_products,product_name)
    if product_name.present?
      vendor_products.joins(:product).where("lower(products.name) LIKE (?)", "%#{product_name.downcase}%")
    end
  end

  def self.filter_by_approval_status(vendor_products,status)
    if status.present?
      vendor_products.joins(:vendor_product_prices).where("vendor_product_prices.status = ?", status).uniq
    end
  end

end
class Vendor < ActiveRecord::Base
  belongs_to :unit
  belongs_to :section
  has_many :vendor_products
  has_many :products, :through => :vendor_products
  attr_accessible :address, :name, :phone, :unit_id, :email, :gst_hash, :latitude, :longitude, :address_phone_no, :pan_no, :recorded_at, :vendor_type, :code, :vendor_products_attributes, :user_vendors_attributes
  
  VENDOR_TYPE = %w(soa_supplier procurement_supplier)

  validates :name, :presence => true
  validates :email, :presence => true
  validates :phone, length: { in: 10..13}
  validates :address_phone_no, :uniqueness => true
  # validates :code, :uniqueness => true
  #validates :address_phone_no, numericality: true, length: {:minimum => 10, :maximum => 14}, :if => Proc.new{self.address_phone_no.present?}
  
  # Model Callbacks
  after_save :generate_vendor_code

  has_many :stock_transactions
  has_many :purchase_orders
  has_many :user_vendors
  has_many :vendor_product_prices
  has_many :inspections, as: :inspected_entity
  has_many :visiting_histories, as: :visited_entity
  accepts_nested_attributes_for :vendor_products, allow_destroy: true
  accepts_nested_attributes_for :user_vendors, allow_destroy: true

  geocoded_by :address
  # after_validation :geocode
  
  reverse_geocoded_by :latitude, :longitude, :address => :address
  # after_validation :reverse_geocode
  after_validation :geocode, :reverse_geocode
  
  # => Model Scopes
  scope :set_unit_id_in,  lambda {|unit_ids|where(["unit_id in (?)", unit_ids])}
  scope :vendor_like, lambda { |vendor| where(["lower(vendors.name) LIKE ?", "%#{vendor.downcase}%"]) }
  scope :by_unit, lambda {|unit_id|where(["unit_id = ?", unit_id])}


  def initialize(attributes=nil, *args)
    super
    if new_record?
      initialized = (attributes || {}).stringify_keys 
      if !initialized.key?('recorded_at')
        self.recorded_at = Time.now.utc
      else
        self.recorded_at = self.recorded_at.utc
      end
      # if !initialized.key?('latitude')
      #   self.address = self.address
      # else
      #   geo_localization = "#{self.latitude},#{self.longitude}"
      #   query = Geocoder.search(geo_localization).first
      #   self.address = query.address
      # end  
    end
  end
  
  def self.import(file)
    imported_vendors =Array.new
    data_errors = Array.new
    CSV.foreach(file.path, headers: true) do |row|
      vendor = Vendor.find_by_id(row["id"]) || Vendor.new
      _unit = Unit.by_unit_name(row["unit"]).first
      vendor.attributes = row.to_hash.slice(*Vendor.accessible_attributes)
      vendor[:unit_id] = _unit.id
      imported_vendors.push vendor
    end
    if imported_vendors.map(&:valid?).all?
      imported_vendors.each(&:save!)
      true
    else
      imported_vendors.each_with_index do |vendor, index|
        unless vendor.valid?
          errors_messages = self.error_messages_for(vendor)
          data_errors.push("Row #{index+2}: #{errors_messages}")
        end
      end
      error_str = data_errors.map { |e| e }.join(', ')
      raise "Data of #{data_errors.size} row(s) prevented the form being saved. #{error_str}"
    end
  end

  def self.error_messages_for(*objects)
    error_string = ""
    objects = objects.map {|o| o.is_a?(String) ? instance_variable_get("@#{o}") : o}.compact
    errors = objects.map {|o| o.errors.full_messages}.flatten
    error_string = errors.map { |e|  "#{e}" }.join(', ') if errors.any?
  end

  def self.filter_by_product(vendors,product_name)
    if product_name.present?
      vendors.joins(:products).where("lower(products.name) LIKE (?)", "%#{product_name.downcase}%").uniq
    end
  end 

  def self.filter_by_approval_status(vendors,status)
    if status.present?
      vendors.joins(:vendor_product_prices).where("vendor_product_prices.status = ?", status).uniq
    end
  end

  private

  def generate_vendor_code
    vendor_codes = Vendor.where("vendor_type = ?", self.vendor_type)
    vendor_codes = vendor_codes.where("id != ?",self.id) if self.vendor_type_changed?
    vendor_codes = vendor_codes.pluck(:code).reject { |vc| vc.to_s.empty? }
    if vendor_codes.present?
      max_vendor_code = vendor_codes.map { |vc| vc.to_i }.max
    else
      max_vendor_code = self.vendor_type == "soa_supplier" ? 0 : 500
    end
    new_vendor_code = max_vendor_code + 1
    new_vendor_code = sprintf '%03d', new_vendor_code
    self.update_column(:code, new_vendor_code)
  end

end
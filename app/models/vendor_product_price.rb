class VendorProductPrice < ActiveRecord::Base
  attr_accessible :vendor_product_id, :vendor_id, :product_id, :unit_id, :unit_price_without_tax, :unit_price_with_tax, :tax_details, :address_of_place, :latitude, :longitude, :delivery_starts, :delivery_ends, :delivery_distance, :delivery_rate_per_km, :delivery_cost, :discount, :quantity, :cost, :visited_by, :viewed_by, :status, :vendor_contract_id, :total_tax_amount, :total_price_with_tax, :total_price_without_tax, :subtotal, :recorded_at, :unit_price, :tax_inclusion, :delivery_charge_inclision, :total_agreed_qty, :supply_interval, :source_location, :source_latitude, :source_longitude, :destination_type, :destination_id

  include ApplicationHelper

  after_create :save_vendor_contract_details
  after_create :calculate_delivery_distance
  after_create :save_prices
  after_create :save_vendor_contract_prices

  # Model Relations
  belongs_to :unit
  belongs_to :vendor_contract
  belongs_to :vendor_product
  belongs_to :vendor
  belongs_to :product
  belongs_to :destination, polymorphic: true

  # Model Validation
  validates :vendor_product, :presence => true
  # validates :destination_id,  :presence => true
  # validates :destination_type,:presence => true

  geocoded_by :source_location
  reverse_geocoded_by :source_latitude, :source_longitude, :address => :source_location
  after_validation :geocode

  #Dynamiv array
  STATUSES = %w(initiated approved rejected)

  API_KEY       = 'Q2JRePQw7py'
  MobileNo      = '9198250510764'
  SenderID      = 'YOTTOL'
  message       = 'Thank you for your order with Yottolabs, Kolkata. Your Order ID is # "#{self.id}". Please give us 30 min to serve you fresh and hot food.'
  Message       = URI.encode(message)
  ServiceName   = 'TEMPLATE_BASED'
  API_BASE_URL  = "smsapi.24x7sms.com/api_2.0/SendSMS.aspx?APIKEY="

  # => Model Scopes
  scope :by_status,  lambda {|status|where(["status = ?", status])}
  scope :by_product,  lambda {|product_id|where(["product_id = ?", product_id])}

  def self.by_recorded_at(from_date, upto_date)
    where('date(recorded_at) BETWEEN ? AND ?',from_date,upto_date)
  end

  def initialize(attributes=nil, *args)
    super
    if new_record?
      initialized = (attributes || {}).stringify_keys
      if !initialized.key?('discount') or attributes[:discount] == ''
        self.discount = 0
      end
      if !initialized.key?('status')
        self.status = 'initiated'
      end  
      if !initialized.key?('recorded_at')
        self.recorded_at = Time.now.utc
      else
        self.recorded_at = self.recorded_at.utc
      end
      if !initialized.key?('delivery_rate_per_km')
        self.delivery_rate_per_km = 0
      end
    end
  end

  private

  def calculate_delivery_distance
  	delivery_distance = calculate_distance_by_lat_long [self.latitude.to_f, self.longitude.to_f],[self.unit.latitude.to_f, self.unit.longitude.to_f]
    update_attribute(:delivery_distance,delivery_distance)
    update_attribute(:delivery_cost,delivery_distance.to_f * self.delivery_rate_per_km.to_f)
  end

  def save_vendor_contract_details
    # update_attributes(:vendor_id=>self.vendor_contract.vendor_id, :unit_id=>self.vendor_contract.unit_id, :latitude=>self.vendor_contract.latitude, :longitude=>self.vendor_contract.longitude, :visited_by=>self.vendor_contract.visited_by)
    update_attributes(:vendor_id=>self.vendor_contract.vendor_id, :unit_id=>self.vendor_contract.unit_id, :visited_by=>self.vendor_contract.visited_by)
  end

  def save_prices
    # _total_tax_amnt = 0
    # tax_array=[]
    # if self.vendor_product.tax_group.present?
    #   self.vendor_product.tax_group.tax_classes.each do |tc|
    #     if tc.tax_type == 'variable'
    #       if ((tc.lower_limit + (tc.lower_limit * tc.ammount)/100)..(tc.upper_limit + (tc.upper_limit * tc.ammount)/100)).include?(self.unit_price_with_tax.to_f)
    #         _total_tax_amnt = _total_tax_amnt + tc[:ammount].to_f
    #       end 
    #     else
    #       _total_tax_amnt = _total_tax_amnt + tc[:ammount].to_f  
    #     end
    #     tax_details = {:tax_class_id => tc.id, :tax_class_name => tc.name, :tax_type => tc.tax_type, :tax_percentage => tc.ammount, :tax_amount => _total_tax_amnt}
    #     tax_array.push(tax_details)
    #   end
    # end
    # unit_price_without_tax = (self.unit_price_with_tax.to_f * 100)/(_total_tax_amnt.to_f + 100)
    # update_attributes(:unit_price_without_tax => unit_price_without_tax,:tax_details => JSON.generate(tax_array),:total_price_without_tax => unit_price_without_tax.to_f * self.quantity, :total_price_with_tax => self.unit_price_with_tax.to_f * self.quantity, :total_tax_amount => (self.unit_price_with_tax.to_f * self.quantity) - (unit_price_without_tax.to_f * self.quantity), :subtotal => self.unit_price_with_tax.to_f * self.quantity - self.discount.to_f, :cost => self.unit_price_with_tax.to_f * self.quantity - self.discount.to_f + self.delivery_cost.to_f)
    update_attributes(:subtotal => self.unit_price.to_f * self.quantity - self.discount.to_f, :cost => self.unit_price.to_f * self.quantity - self.discount.to_f + self.delivery_cost.to_f)
  end

  def save_vendor_contract_prices
    # self.vendor_contract.update_attributes(:total_tax_amount => self.vendor_contract.vendor_product_prices.sum(:total_tax_amount), :grand_total => self.vendor_contract.vendor_product_prices.sum(:cost), :total_contract_price => self.vendor_contract.vendor_product_prices.sum(:subtotal))
    self.vendor_contract.update_attributes(:grand_total => self.vendor_contract.vendor_product_prices.sum(:cost), :total_contract_price => self.vendor_contract.vendor_product_prices.sum(:subtotal))
  end

  def self.send_sms
    puts 'sending sms'
    # uri = "http://#{API_BASE_URL}#{API_KEY}&MobileNo=#{MobileNo}&SenderID=#{SenderID}&Message=#{Message}&ServiceName=#{ServiceName}"
    # puts uri
    # rest_response = RestClient.get uri
    # puts rest_response.body
  end

end
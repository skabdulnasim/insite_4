class BillSplit < ActiveRecord::Base
  attr_accessible :bill_amount, :bill_id, :discount, :grand_total, :split_type, :tax_amount, :unit_id, :user_id, :recorded_at, :remarks, :biller_id, :checksum, :bill_split_products_attributes
  
  # => Model relations
  belongs_to :bill
  has_many :bill_split_products
  has_one :split_settlement
  belongs_to :biller, :polymorphic => true


  accepts_nested_attributes_for :bill_split_products
  # => Defining Bill statuses
  SPLIT_TYPE = %w(by_product by_amount)

  # => Dynamic methods for bill statuses
  SPLIT_TYPE.each do |type|
    define_method "#{type}?" do
      self.type == type
    end
  end

  # => Model validations
  validates :bill_id,     :presence => true
  #validates :bill_amount, :presence => true
  #validates :grand_total, :presence => true
  validates :split_type,  :presence => true
  validates :unit_id,     :presence => true
  validates :user_id,     :presence => true

  scope :by_bill, lambda {|bill_id|where(["bill_id=?", bill_id])}
  
  def initialize(attributes=nil, *args)
    super
    if new_record?
      initialized = (attributes || {}).stringify_keys
      if self.split_type == 'by_product'
        self.bill_amount = self.bill_split_products.map { |e| e.price }.sum
        self.tax_amount  = self.bill_split_products.map { |e| e.tax_amount }.sum
        subtotal         = self.bill_split_products.map { |e| e.subtotal }.sum
        discount         = (self.bill.discount/self.bill.grand_total)*100
        discount         = (discount*subtotal)/100
        self.discount    = discount
        self.grand_total = bill_roundoff_disabled? ? (subtotal - discount.to_f).round(2) : (subtotal - discount.to_f).round
      else
        self.tax_amount  = (self.bill.tax_amount/self.bill.grand_total)*self.grand_total
        self.bill_amount = (self.grand_total - self.tax_amount)
        discount         = (self.bill.discount/self.bill.grand_total)*100
        self.discount    = (discount*self.grand_total)/100
      end  
      if !initialized.key?('status')
        self.status = 'unpaid'
      end
      if !initialized.key?('recorded_at')
        self.recorded_at = Time.now.utc
      else
        self.recorded_at = self.recorded_at.utc
      end 
    end
  end

  # Return true if bill roundoff is disabled
  def bill_roundoff_disabled?
    AppConfiguration.get_config_value('apply_bill_roundoff') == 'disabled'
  end

  def self.create_split_bill(_bill_id,_unit_id,_user_id,_split_type,_bill_amount,_tax_amount,_discount,_grand_total,_product_details)
    _bill = Bill.find(_bill_id)
    _new_split = BillSplit.new(:bill_amount=>_bill_amount, :discount=>_discount, :grand_total=>_grand_total, :split_type=>_split_type, :tax_amount=>_tax_amount, :unit_id=>_unit_id, :user_id=>_user_id)
    if _bill.bill_splits << _new_split && _split_type == 'by_product' 
      _product_details.each do |pd|
        _new_pro_dt = BillSplitProduct.new(:product_id=>pd['product_id'], :quantity=>pd['quantity'], :price=>pd['price'])
        _new_split.bill_split_products << _new_pro_dt
      end
    end    
  end

  def paid! 
    update_attribute(:status, 'paid')
  end

  private

end

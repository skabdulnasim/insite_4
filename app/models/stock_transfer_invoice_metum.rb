class StockTransferInvoiceMetum < ActiveRecord::Base
  attr_accessible :price, :product_id, :quantity, :stock_transfer_invoice_id, :tax_group_id, :tax_amount, :price_with_tax
  belongs_to :stock_transfer_invoice
  belongs_to :product
  belongs_to :tax_group

  before_validation :apply_tax
  
  # => Model validations
  validates :price, :presence => true
  validates :product_id, :presence => true
  validates :quantity, :presence => true
  validates :stock_transfer_invoice_id, :presence => true

  scope :by_product, lambda {|product_id|where(["product_id=?", product_id])}
  
  def self.create_invoice_meta(price,product_id,quantity,invoice_id,tax_group_id)
  	_invoice_meta = StockTransferInvoiceMetum.create(:price=>price,:product_id=>product_id,:quantity=>quantity,:stock_transfer_invoice_id=>invoice_id, :tax_group_id=> tax_group_id)
  	return _invoice_meta
  end

  def apply_tax
    if self.price.present? and self.tax_group_id.present?
      self.tax_amount = calculate_tax_amount
      self.price_with_tax = self.price + self.tax_amount
    end
  end 
  
  def calculate_tax_amount
    (self.price * self.tax_group.total_amnt / 100) + self.tax_group.fixed_amount
  end 

end

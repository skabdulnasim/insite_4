class StockTransferInvoice < ActiveRecord::Base
  attr_accessible :price, :stock_transfer_id
  belongs_to :stock_transfer
  has_many :stock_transfer_invoice_meta

  before_update :set_invoice_price

  # => Model validations
  validates :stock_transfer_id, :presence => true

  def self.create_invoice(stock_transfer_id,price)
  	_invoice = StockTransferInvoice.create(:price=>price,:stock_transfer_id=>stock_transfer_id)
  	return _invoice
  end

  def set_invoice_price
  	price = 0
  	self.stock_transfer_invoice_meta.each do |meta|
  		price += meta.price_with_tax.present? ? meta.price_with_tax : meta.price
  	end
  	self.price = price
  end
end

class StockPurchasePayment < ActiveRecord::Base
  attr_accessible :payment_amount, :payment_mode, :stock_purchase_id, :vendor_id, :details, :payment_date

  belongs_to :stock_purchases
end

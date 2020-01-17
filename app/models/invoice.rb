class Invoice < ActiveRecord::Base
  attr_accessible :from_store_id, :order_id, :payment_mode, :price, :product_id, :quantity, :serial_no, :to_store_id
end

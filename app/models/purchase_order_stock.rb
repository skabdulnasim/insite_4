class PurchaseOrderStock < ActiveRecord::Base
  attr_accessible :available_stock, :consumption_log, :order_date, :product_id, :price, :po_stock, :receive_date, :received_stock, :status, :status_log, :vendor_id, :purchase_order_id, :po_serial_no 
end

class OrderCartItem < ActiveRecord::Base
  attr_accessible :color_id, :customer_id, :lot_id, :menu_product_id, :model_no, :order_cart_id, :product_id, :quantity, :size_id, :status, :stock_status
end

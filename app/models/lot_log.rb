class LotLog < ActiveRecord::Base
  attr_accessible :after_operation_price, :before_operation_price, :decrease, :increase, :lot_id, :menu_product_id, :product_id, :user_id
end

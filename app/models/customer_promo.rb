class CustomerPromo < ActiveRecord::Base
  attr_accessible :count, :customer_id, :promo_code, :promo_id, :unit_id
end

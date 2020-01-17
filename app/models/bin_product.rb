class BinProduct < ActiveRecord::Base
  attr_accessible :bin_id, :bin_unique_id, :product_id, :product_quantity, :sku
  belongs_to :bin
  belongs_to :product
end

class BoxItem < ActiveRecord::Base
  attr_accessible :sku, :box_id, :product_id, :stock_id, :qty

  # Model Relations
  belongs_to :box
  belongs_to :product
  belongs_to :stock
end
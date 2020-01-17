class Box < ActiveRecord::Base
  attr_accessible :sku, :boxing_id, :product_id, :stock_id

  # Model Relations
  belongs_to :boxing
  belongs_to :product
  belongs_to :stock
  has_many :box_items
end
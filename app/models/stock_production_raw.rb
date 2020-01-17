class StockProductionRaw < ActiveRecord::Base
  attr_accessible :product_id, :quantity, :stock_production_meta_id, :target_product_id, :store_id, :product_cost

  # => Model relations
  belongs_to :product
  belongs_to :stock_production_meta
  belongs_to :target_product, class_name: "Product", foreign_key: "target_product_id"
  # => Model Validations
  validates :product_id,              :presence => true
  validates :store_id,                :presence => true
  validates :quantity,                :presence => true
  validates :stock_production_meta_id,:presence => true
  validates :target_product_id,       :presence => true

  #Model Scopes
  scope :set_store,   lambda {|store|where(["store_id=?", store])}
  scope :set_product, lambda {|pro|where(["product_id=?", pro])}
  scope :last_day,    lambda { where(["created_at > ?",1.day.ago]) }
  scope :last_week,   lambda { where(["created_at > ?",7.day.ago]) }
end

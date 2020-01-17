class Simo < ActiveRecord::Base
  attr_accessible :store_id, :status, :isStockAdded
  has_one :simo_input_product
  has_many :stocks, as: :stock_transaction
  belongs_to :simo

  scope :initial, lambda { where(["status = ?",'initial_state']) }
  scope :processed, lambda { where(["status = ?",'processed'])}
  scope :finished, lambda { where(["status =?", 'finished'])}
  scope :set_store, lambda {|store_id|where(["store_id=?", store_id])}
 	scope :by_date_range, lambda {|from_date, upto_date|where('created_at BETWEEN ? AND ?',from_date,upto_date)}
end
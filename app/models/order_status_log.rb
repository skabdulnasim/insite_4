class OrderStatusLog < ActiveRecord::Base
	default_scope { order(created_at: :desc) }
  attr_accessible :order_id, :order_status_id, :order_status_name, :outlet_id, :user_id

  ### => Scopes
  scope :by_unit,          	lambda {|unit_id|where(["unit_id=?", unit_id])}
  scope :by_date_range,		lambda {|from_date, upto_date|where('created_at BETWEEN ? AND ?',from_date,upto_date)}
end
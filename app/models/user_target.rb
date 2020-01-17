class UserTarget < ActiveRecord::Base
  attr_accessible :child_user_id, :duration, :from_date, :is_approved, :parent_user_id, :rejection_reason, :target_amount, :target_type, :to_date, :parent_target

  TARGET_TYPE = %w(by_product)
  DURATION = %w(weekly monthly quaterly half_yearly yearly)

  # Model Relations
  belongs_to :child_user, class_name: "User", foreign_key: "child_user_id"
  belongs_to :parent_user, class_name: "User", foreign_key: "parent_user_id"
  has_many :child_targets, class_name: "UserTarget", foreign_key: "parent_target"
  has_many :resource_targets
  has_many :user_target_products
  # validates :child_user_id, uniqueness: { scope: :from_date }
  
  # => Model scopes
	scope :by_date,          lambda {|date|where('? BETWEEN from_date AND to_date',date)}
	scope :by_child_user,    lambda {|child_user_id|where('child_user_id = ?',child_user_id)}
  scope :by_from_to_date,  lambda {|from_date,to_date|where('from_date = ? AND to_date = ?',from_date,to_date)}
  scope :by_tsp_ids,       lambda {|tsp_ids|where("child_user_id IN(?)",tsp_ids)}
  scope :by_start_end_date,lambda {|from_date,to_date|where("from_date=? AND to_date=?",from_date,to_date)}
  scope :by_month_range,   lambda {|from_month, upto_month|where('extract(month from from_date) BETWEEN ? AND ? OR extract(month from to_date) BETWEEN ? AND ?',from_month,upto_month,from_month,upto_month)}
  scope :by_parent_id,     lambda {|parent_target_id| where("parent_target=?",parent_target_id)}
end

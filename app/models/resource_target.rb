class ResourceTarget < ActiveRecord::Base
  attr_accessible :resource_id, :target_amount, :target_by, :user_target_id,:from_date,:to_date,:target_type
  audited
  # Model Relations
  belongs_to :user_target
  belongs_to :user, :foreign_key => :target_by
  belongs_to :resource
  has_many :user_target_products
  # Model Scopes
  scope :set_target_bys, lambda{|target_bys| where(["target_by IN (?)",target_bys])}
  scope :set_target_by, lambda{|target_by| where(["target_by= ?",target_by])}
  scope :set_resource, lambda{|resource_id| where(["resource_id= ?",resource_id])}
  scope :by_date, lambda {|date|where('? BETWEEN from_date AND to_date',date)}
  scope :date_range, lambda { |from_datetime,to_datetime| where('from_date=? and to_date=?',from_datetime, to_datetime)}
  scope :by_month_range, lambda {|from_month, upto_month|where('extract(month from from_date) BETWEEN ? AND ? OR extract(month from to_date) BETWEEN ? AND ?',from_month,upto_month,from_month,upto_month)}
  scope :by_year_range, lambda {|from_year, upto_year|where('extract(year from from_date) BETWEEN ? AND ? OR extract(year from to_date) BETWEEN ? AND ?',from_year,upto_year,from_year,upto_year)}
  scope :by_user_target_id, lambda{|user_target_id|where("user_target_id=?",user_target_id)}
end
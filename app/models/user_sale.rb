class UserSale < ActiveRecord::Base
  attr_accessible :price_with_tax, :price_without_tax, :product_id, :quantity, :recorded_at, :resource_id, :user_id, :owner_commission, :thirdparty_commission
  belongs_to :resource
  belongs_to :user
  scope :by_user_id, lambda {|user_id|where(["user_id = ?", user_id])}
  scope :by_user_ids, lambda {|user_ids|where(["user_id in (?)", user_ids])}
  scope :by_product_id, lambda {|product_id|where(["product_id = ?", product_id])}
  scope :by_product_id_in, lambda {|product_ids|where(["product_id IN(?)", product_ids])}
  scope :by_resource_id, lambda {|resource_id|where(["resource_id = ?", resource_id])}
  scope :by_resource_ids, lambda {|resource_ids|where(["resource_id in (?)", resource_ids])}
  scope :by_recorded_at, lambda {|date_only|where(["recorded_at = ?", date_only])}
  scope :by_recorded_at_between, lambda {|from_date,to_date|where(["recorded_at BETWEEN ? AND ?", from_date,to_date])}
  scope :by_recorded_at_month, lambda {|month|where(["extract(month from recorded_at) = ?", month])}
  scope :by_recorded_at_year, lambda {|year|where(["extract(year from recorded_at) = ?", year])}
  scope :by_recorded_at_month_range, lambda {|from_month,to_month|where(["extract(month from recorded_at) BETWEEN ? AND ?", from_month,to_month])}
  scope :by_recorded_at_year_range, lambda {|from_year,to_year|where(["extract(year from recorded_at) BETWEEN ? AND ?", from_year,to_year])}
end
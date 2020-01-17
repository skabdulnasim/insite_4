class AddColumnsToCoupons < ActiveRecord::Migration
  def change
  	add_column :coupons, :code, :string
  	add_column :coupons, :coupon_type, :string
  	add_column :coupons, :amount_type, :string
  	add_column :coupons, :amount, :float
  	add_column :coupons, :count, :integer
  	add_column :coupons, :status, :string
  	add_column :coupons, :from_date, :date
  	add_column :coupons, :to_date, :date
  end
end

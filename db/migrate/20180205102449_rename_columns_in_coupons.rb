class RenameColumnsInCoupons < ActiveRecord::Migration
  def change
  	rename_column :coupons, :from_date, :valid_from
  	rename_column :coupons, :to_date, :valid_to
  end
end

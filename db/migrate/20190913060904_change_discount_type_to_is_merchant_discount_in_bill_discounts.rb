class ChangeDiscountTypeToIsMerchantDiscountInBillDiscounts < ActiveRecord::Migration
  def change
  	rename_column :bill_discounts, :discount_type, :is_merchant_discount
  end
end

class AddBillAmountAndMaxDiscountToAlphaPromotions < ActiveRecord::Migration
  def change
  	add_column :alpha_promotions, :bill_amount, :float
  	add_column :alpha_promotions, :max_discount, :float
  end
end

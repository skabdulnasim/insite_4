class AddDiscountTypeToBillDiscounts < ActiveRecord::Migration
  def change
    add_column :bill_discounts, :discount_type, :string
  end
end

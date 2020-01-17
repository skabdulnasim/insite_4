class AddRateToBillDiscounts < ActiveRecord::Migration
  def change
    add_column :bill_discounts, :rate, :float
  end
end

class AddDiscountPercentageToBills < ActiveRecord::Migration
  def change
    add_column :bills, :discount_percenatge, :float
  end
end

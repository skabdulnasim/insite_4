class AddDiscountWithOutTaxToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :discount_percentage, :float
  end
end

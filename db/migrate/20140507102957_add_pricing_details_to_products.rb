class AddPricingDetailsToProducts < ActiveRecord::Migration
  def change
    add_column :products, :sell_price, :float
    add_column :products, :valid_from, :datetime
    add_column :products, :valid_to, :datetime
  end
end

class AddMrpAndLandingPriceToStocks < ActiveRecord::Migration
  def change
    add_column :stocks, :mrp, :float
    add_column :stocks, :landing_price, :float
  end
end

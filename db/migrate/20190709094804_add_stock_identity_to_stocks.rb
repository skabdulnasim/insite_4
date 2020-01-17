class AddStockIdentityToStocks < ActiveRecord::Migration
  def change
    add_column :stocks, :stock_identity, :string
  end
end

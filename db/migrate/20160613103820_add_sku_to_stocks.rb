class AddSkuToStocks < ActiveRecord::Migration
  def change
    unless column_exists? :stocks, :sku
      add_column :stocks, :sku, :string
    end
  end
end

class AddProcurmentPriceToStockTransferMetum < ActiveRecord::Migration
  def change
    add_column :stock_transfer_meta, :procurment_price, :float
  end
end

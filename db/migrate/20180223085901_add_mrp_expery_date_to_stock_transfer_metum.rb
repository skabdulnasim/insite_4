class AddMrpExperyDateToStockTransferMetum < ActiveRecord::Migration
  def change
    add_column :stock_transfer_meta, :expery_date, :date
    add_column :stock_transfer_meta, :mrp, :float
    add_column :stock_transfer_meta, :sale_price_without_tax, :float
    add_column :stock_transfer_meta, :color_name, :string
    add_column :stock_transfer_meta, :model_number, :string
    add_column :stock_transfer_meta, :size, :string
  end
end

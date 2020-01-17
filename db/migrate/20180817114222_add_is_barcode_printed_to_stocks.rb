class AddIsBarcodePrintedToStocks < ActiveRecord::Migration
  def change
    add_column :stocks, :is_barcode_printed, :integer
  end
end

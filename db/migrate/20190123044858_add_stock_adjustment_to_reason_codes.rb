class AddStockAdjustmentToReasonCodes < ActiveRecord::Migration
  def change
    add_column :reason_codes, :stock_adjustment, :boolean
  end
end

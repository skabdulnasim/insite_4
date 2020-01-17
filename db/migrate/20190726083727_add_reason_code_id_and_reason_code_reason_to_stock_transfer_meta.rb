class AddReasonCodeIdAndReasonCodeReasonToStockTransferMeta < ActiveRecord::Migration
  def change
    add_column :stock_transfer_meta, :reason_code_id, :integer
    add_column :stock_transfer_meta, :reason_code, :text
  end
end

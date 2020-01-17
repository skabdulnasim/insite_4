class ChangeStockPuchaseIdToStockPurchaseId < ActiveRecord::Migration
  def up
  	rename_column :stock_purchase_payments, :stock_puchase_id, :stock_purchase_id
  end
end

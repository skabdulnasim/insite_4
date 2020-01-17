class ChangeUrbanpiparStockStatusesToThirdpartyItemActions < ActiveRecord::Migration
  def change
	  rename_table :urbanpipar_stock_statuses, :thirdparty_item_actions
	end
end

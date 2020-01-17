class ChangeStockStatusToActionAndDeleteSelectedChannelInThirdpartyItemActions < ActiveRecord::Migration
  def change
    rename_column :thirdparty_item_actions, :stock_status, :action
  end
end

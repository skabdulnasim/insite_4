class AddStockIdentityToStockTransferMeta < ActiveRecord::Migration
  def change
    add_column :stock_transfer_meta, :stock_identity, :string
  end
end

class AddAttachmentImageToStockPurchases < ActiveRecord::Migration
  def up
    add_attachment :stock_purchases, :attachment
  end

  def down
    remove_attachment :stock_purchases, :attachment
  end
end

class AddStockDebitFlagToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :is_stock_debited, :string
    add_column :order_detail_combinations, :is_stock_debited, :string
  end
end

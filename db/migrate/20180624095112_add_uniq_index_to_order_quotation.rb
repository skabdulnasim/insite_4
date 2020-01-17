  class AddUniqIndexToOrderQuotation < ActiveRecord::Migration
  def change
    add_index :orders_quotations, [:order_id, :quotation_id]
    add_index :orders_quotations, [:quotation_id, :order_id]
  end
end

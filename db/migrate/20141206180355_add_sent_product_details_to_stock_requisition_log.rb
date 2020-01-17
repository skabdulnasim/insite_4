class AddSentProductDetailsToStockRequisitionLog < ActiveRecord::Migration
  def change
    add_column :store_requisition_logs, :sent_product_details, :text
  end
end

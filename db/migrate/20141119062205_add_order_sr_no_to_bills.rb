class AddOrderSrNoToBills < ActiveRecord::Migration
  def change
    add_column :bills, :order_sr_no, :text
  end
end

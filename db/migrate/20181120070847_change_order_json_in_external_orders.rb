class ChangeOrderJsonInExternalOrders < ActiveRecord::Migration
  def change
    change_column :external_orders, :order_json, :text
  end
end

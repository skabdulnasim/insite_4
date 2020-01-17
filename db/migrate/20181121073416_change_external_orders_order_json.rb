class ChangeExternalOrdersOrderJson < ActiveRecord::Migration
  def change
    rename_column :external_orders, :order_json, :order
    add_column :external_orders, :customer, :text
  end
end

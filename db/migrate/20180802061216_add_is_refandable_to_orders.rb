class AddIsRefandableToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :is_refandable, :string
  end
end

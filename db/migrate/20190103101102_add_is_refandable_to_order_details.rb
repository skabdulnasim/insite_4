class AddIsRefandableToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :is_refandable, :string
  end
end

class AddHoldToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :hold, :string
  end
end

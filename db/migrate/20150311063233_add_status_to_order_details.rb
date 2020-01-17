class AddStatusToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :status, :string
  end
end

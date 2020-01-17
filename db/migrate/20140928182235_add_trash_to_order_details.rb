class AddTrashToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :trash, :integer
  end
end

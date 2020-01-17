class AddTrashToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :trash, :integer
  end
end

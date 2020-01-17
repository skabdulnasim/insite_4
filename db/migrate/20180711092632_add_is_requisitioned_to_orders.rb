class AddIsRequisitionedToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :is_requisitioned, :integer
  end
end

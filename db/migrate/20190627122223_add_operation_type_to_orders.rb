class AddOperationTypeToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :operation_type, :string
  end
end

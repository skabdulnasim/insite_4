class AddDeliveryPolymorphicToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :deliverable_id, :integer
    add_column :orders, :deliverable_type, :string
  end
end

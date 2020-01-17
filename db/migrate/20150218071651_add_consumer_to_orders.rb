class AddConsumerToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :consumer_id, :integer
    add_column :orders, :consumer_type, :string
  end
end

class AddThirdPartyOrderIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :third_party_order_id, :string
  end
end

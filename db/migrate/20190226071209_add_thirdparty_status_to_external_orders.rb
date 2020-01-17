class AddThirdpartyStatusToExternalOrders < ActiveRecord::Migration
  def change
    add_column :external_orders, :thirdparty_status, :string
  end
end

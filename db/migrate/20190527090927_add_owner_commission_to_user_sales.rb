class AddOwnerCommissionToUserSales < ActiveRecord::Migration
  def change
    add_column :user_sales, :owner_commission, :float
    add_column :user_sales, :thirdparty_commission, :float
  end
end

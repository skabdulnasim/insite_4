class AddExpiryDateToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :expiry_date, :date
  end
end

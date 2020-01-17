class AddPreferencesToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :preferences, :text
  end
end

class AddDelivaryDateToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :delivary_date, :datetime
  end
end

class AddDelivaryDateToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :delivary_date, :datetime
  end
end

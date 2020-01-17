class AddSortIdToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :sort_id, :integer
  end
end

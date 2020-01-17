class AddOrderIdToReturnItems < ActiveRecord::Migration
  def change
    add_column :return_items, :order_id, :integer
  end
end

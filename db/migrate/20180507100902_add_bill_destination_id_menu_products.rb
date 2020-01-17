class AddBillDestinationIdMenuProducts < ActiveRecord::Migration
  def change
    add_column :menu_products, :bill_destination_id, :integer
  end
end

class AddHsnToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :hsn_code, :string
  end
end

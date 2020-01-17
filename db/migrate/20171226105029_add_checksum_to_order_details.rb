class AddChecksumToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :checksum, :text
  end
end

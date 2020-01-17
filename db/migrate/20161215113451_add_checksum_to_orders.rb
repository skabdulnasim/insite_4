class AddChecksumToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :checksum, :string
    add_index :orders, :checksum, :unique => true
  end
end

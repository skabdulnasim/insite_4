class AddPropertiesToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :properties, :hstore
    add_hstore_index :order_details, :properties
  end
end

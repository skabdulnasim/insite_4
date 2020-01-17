class AddDeviceIdToBills < ActiveRecord::Migration
  def change
    unless column_exists? :bills, :device_id
      add_column :bills, :device_id, :integer
    end
    unless column_exists? :bills, :serial_no
      add_column :bills, :serial_no, :integer
    end
    unless column_exists? :orders, :device_id
      add_column :orders, :device_id, :integer
    end
    unless column_exists? :orders, :serial_no
      add_column :orders, :serial_no, :integer
    end    
    if column_exists? :bills, :order_sr_no
      remove_column :bills, :order_sr_no
    end    
  end
end

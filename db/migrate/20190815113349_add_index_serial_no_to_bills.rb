class AddIndexSerialNoToBills < ActiveRecord::Migration
  def change
  	remove_index  :bills, :name=>"index_bills_on_serial_no" if index_exists?(:bills, :serial_no)
  	add_index :bills, :serial_no, unique: true
  end
end

class ChangeSerialNoTypeInBills < ActiveRecord::Migration
  def up
    change_column :bills, :serial_no, :string 
  end

  
end

class AddBillSerialNoToCashIn < ActiveRecord::Migration
  def change
    add_column :cash_ins, :bill_serial_no, :string
  end
end

class ChangeDataTypeForTableReservationPhoneNo < ActiveRecord::Migration
  def self.up
    change_table :table_reservations do |t|
      t.change :contact_no, :string
    end
  end
  def self.down
    change_table :table_reservations do |t|
      t.change :contact_no, :integer
    end
  end
end

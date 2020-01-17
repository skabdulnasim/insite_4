class ChangeStatusTableReservation < ActiveRecord::Migration
  def self.up
    change_table :table_reservations do |t|
      t.change :status, :string
    end
  end
  def self.down
    change_table :table_reservations do |t|
      t.change :status, :text
    end
  end
end

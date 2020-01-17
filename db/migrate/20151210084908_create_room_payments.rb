class CreateRoomPayments < ActiveRecord::Migration
  def change
    create_table :room_payments do |t|
      t.integer :room_id
      t.integer :room_name
      t.float :amount

      t.timestamps
    end
  end
end

class CreateUserBits < ActiveRecord::Migration
  def change
    create_table :user_bits do |t|
      t.integer :user_id
      t.integer :bit_id
      t.date :visit_date

      t.timestamps
    end
  end
end

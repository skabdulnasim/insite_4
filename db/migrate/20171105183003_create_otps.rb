class CreateOtps < ActiveRecord::Migration
  def change
    create_table :otps do |t|
      t.string :phone_number
      t.string :otp
      t.boolean :verified

      t.timestamps
    end
  end
end

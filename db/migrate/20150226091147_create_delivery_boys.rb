class CreateDeliveryBoys < ActiveRecord::Migration
  def change
    create_table :delivery_boys do |t|
      t.string :name
      t.string :email
      t.integer :phone_no
      t.string :address

      t.timestamps
    end
  end
end

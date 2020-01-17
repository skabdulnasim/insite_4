class CreateCoupons < ActiveRecord::Migration
  def change
    create_table :coupons do |t|
      t.string :no
      t.date :validity
      t.string :name
      t.string :provider
      t.integer :denomination
      t.integer :amount

      t.timestamps
    end
  end
end

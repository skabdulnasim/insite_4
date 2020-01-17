class CreateProformas < ActiveRecord::Migration
  def change
    create_table :proformas do |t|
      t.float :discount
      t.float :grand_total
      t.float :proforma_amount
      t.date :recorded_at
      t.string :remarks
      t.float :tax_amount
      t.float :roundoff
      t.string :serial_no
      t.string :status
      t.integer :unit_id
      t.string :device_id
      t.integer :customer_id
      t.integer :user_id

      t.timestamps
    end
  end
end

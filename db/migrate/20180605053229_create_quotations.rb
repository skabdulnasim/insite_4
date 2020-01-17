class CreateQuotations < ActiveRecord::Migration
  def change
    create_table :quotations do |t|
      t.float :quotation_amount
      t.float :discount
      t.float :grand_total
      t.float :tax_amount
      t.references :unit
      t.string :status
      t.references :user
      t.string :serial_no
      t.string :device_id
      t.string :remarks
      t.float :roundoff
      t.datetime :recorded_at
      t.references :customer

      t.timestamps
    end
    add_index :quotations, :unit_id
    add_index :quotations, :user_id
    add_index :quotations, :customer_id
  end
end

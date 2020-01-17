class CreateCustomerNotes < ActiveRecord::Migration
  def change
    create_table :customer_notes do |t|
      t.integer :customer_id
      t.datetime :recorded_at
      t.text :notes

      t.timestamps
    end
  end
end

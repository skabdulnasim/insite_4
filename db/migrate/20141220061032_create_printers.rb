class CreatePrinters < ActiveRecord::Migration
  def change
    create_table :printers do |t|
      t.string :name
      t.text :ip
      t.integer :unit_id
      t.integer :assignable_id
      t.string :assignable_type

      t.timestamps
    end
  end
end

class CreateZones < ActiveRecord::Migration
  def change
    create_table :zones do |t|
      t.string :name
      t.text :descriptions
      t.boolean :status

      t.timestamps
    end
  end
end

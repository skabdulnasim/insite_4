class CreateAreas < ActiveRecord::Migration
  def change
    create_table :areas do |t|
      t.string :name
      t.text :descriptions
      t.boolean :status

      t.timestamps
    end
  end
end

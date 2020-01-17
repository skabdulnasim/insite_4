class CreateSections < ActiveRecord::Migration
  def change
    create_table :sections do |t|
      t.string :name
      t.text :description
      t.references :unit

      t.timestamps
    end
    add_index :sections, :unit_id
  end
end

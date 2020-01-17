class CreateResources < ActiveRecord::Migration
  def change
    create_table :resources do |t|
      t.string :name
      t.references :resource_type
      t.hstore :properties

      t.timestamps
    end
    add_index :resources, :resource_type_id
    add_hstore_index :resources, :properties
  end
end

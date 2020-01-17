class CreateResourceFields < ActiveRecord::Migration
  def change
    create_table :resource_fields do |t|
      t.string :name
      t.string :field_type
      t.boolean :required
      t.boolean :is_sortable
      t.boolean :is_unique
      t.boolean :is_compareable
      t.belongs_to :resource_type

      t.timestamps
    end
    add_index :resource_fields, :resource_type_id
  end
end

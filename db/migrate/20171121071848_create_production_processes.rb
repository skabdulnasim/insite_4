class CreateProductionProcesses < ActiveRecord::Migration
  def change
    create_table :production_processes do |t|
      t.string :name
      t.string :short_name
      t.string :local_name
      t.integer :basic_unit_id
      t.integer :conjugated_unit_id
      t.integer :physical_type_id
      t.integer :category_id
      t.float :cost

      t.timestamps
    end
  end
end

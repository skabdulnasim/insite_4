class CreateDependsOnProcesses < ActiveRecord::Migration
  def change
    create_table :depends_on_processes do |t|
      t.integer :process_composition_id
      t.integer :process_id

      t.timestamps
    end
  end
end

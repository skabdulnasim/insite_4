class CreateUnits < ActiveRecord::Migration
  def change
    create_table :units do |t|
      t.boolean :is_trashed
      t.timestamps
    end
  end
end

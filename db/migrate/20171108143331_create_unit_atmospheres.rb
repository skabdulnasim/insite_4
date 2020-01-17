class CreateUnitAtmospheres < ActiveRecord::Migration
  def change
    create_table :unit_atmospheres do |t|
      t.integer :unit_id
      t.integer :atmosphere_id

      t.timestamps
    end
  end
end

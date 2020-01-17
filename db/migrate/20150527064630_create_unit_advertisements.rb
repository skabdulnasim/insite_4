class CreateUnitAdvertisements < ActiveRecord::Migration
  def change
    create_table :unit_advertisements do |t|
      t.integer :unit_id
      t.integer :advertisement_id

      t.timestamps
    end
  end
end

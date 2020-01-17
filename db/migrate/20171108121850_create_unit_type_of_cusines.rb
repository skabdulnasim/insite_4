class CreateUnitTypeOfCusines < ActiveRecord::Migration
  def change
    create_table :unit_type_of_cusines do |t|
      t.integer :unit_id
      t.integer :type_of_cuisine_id

      t.timestamps
    end
  end
end

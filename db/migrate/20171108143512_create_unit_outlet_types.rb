class CreateUnitOutletTypes < ActiveRecord::Migration
  def change
    create_table :unit_outlet_types do |t|
      t.integer :unit_id
      t.integer :outlet_type_id

      t.timestamps
    end
  end
end

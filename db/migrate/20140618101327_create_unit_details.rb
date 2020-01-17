class CreateUnitDetails < ActiveRecord::Migration
  def change
    create_table :unit_details do |t|

      t.timestamps
    end
  end
end

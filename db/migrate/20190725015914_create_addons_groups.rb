class CreateAddonsGroups < ActiveRecord::Migration
  def change
    create_table :addons_groups do |t|
      t.string :title
      t.integer :unit_id

      t.timestamps
    end
  end
end

class CreatePackageUnits < ActiveRecord::Migration
  def change
    create_table :package_units do |t|
      t.string :unit_name
      t.integer :parent
      t.integer :package_id

      t.timestamps
    end
  end
end

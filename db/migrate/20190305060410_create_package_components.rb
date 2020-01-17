class CreatePackageComponents < ActiveRecord::Migration
  def change
    create_table :package_components do |t|
      t.string :name
      t.integer :basic_unit_id
      t.integer :category_id

      t.timestamps
    end
  end
end

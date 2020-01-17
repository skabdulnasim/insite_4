class CreateUnitImages < ActiveRecord::Migration
  def change
    create_table :unit_images do |t|
      t.integer :unit_id
      t.string :image

      t.timestamps
    end
  end
end

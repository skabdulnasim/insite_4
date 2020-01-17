class CreateTypeOfCuisines < ActiveRecord::Migration
  def change
    create_table :type_of_cuisines do |t|
      t.string :name

      t.timestamps
    end
  end
end

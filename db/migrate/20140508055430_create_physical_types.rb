class CreatePhysicalTypes < ActiveRecord::Migration
  def change
    create_table :physical_types do |t|
      t.string :name

      t.timestamps
    end
  end
end

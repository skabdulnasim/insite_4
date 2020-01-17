class CreateAtmospheres < ActiveRecord::Migration
  def change
    create_table :atmospheres do |t|
      t.string :name

      t.timestamps
    end
  end
end

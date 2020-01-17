class CreateTermAttributes < ActiveRecord::Migration
  def change
    create_table :term_attributes do |t|
      t.string :name

      t.timestamps
    end
  end
end

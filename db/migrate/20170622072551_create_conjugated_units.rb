class CreateConjugatedUnits < ActiveRecord::Migration
  def change
    create_table :conjugated_units do |t|
      t.string :conjugated_name

      t.timestamps
    end
  end
end

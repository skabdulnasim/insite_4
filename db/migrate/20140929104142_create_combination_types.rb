class CreateCombinationTypes < ActiveRecord::Migration
  def change
    create_table :combination_types do |t|
      t.string :name

      t.timestamps
    end
  end
end

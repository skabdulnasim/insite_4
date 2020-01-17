class CreateCombinationsRules < ActiveRecord::Migration
  def change
    create_table :combinations_rules do |t|
      t.string :name
      t.string :max_qty
      t.string :min_qty

      t.timestamps
    end
  end
end

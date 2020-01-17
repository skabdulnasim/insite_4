class CreatePercentages < ActiveRecord::Migration
  def change
    create_table :percentages do |t|
      t.string :name
      t.float :value

      t.timestamps
    end
  end
end

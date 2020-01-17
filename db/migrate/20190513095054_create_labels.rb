class CreateLabels < ActiveRecord::Migration
  def change
    create_table :labels do |t|
      t.string :type
      t.string :name
      t.boolean :status

      t.timestamps
    end
  end
end

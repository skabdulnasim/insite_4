class CreateBoxings < ActiveRecord::Migration
  def change
    create_table :boxings do |t|
      t.string :name

      t.timestamps
    end
  end
end

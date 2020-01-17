class CreateTableTypes < ActiveRecord::Migration
  def change
    create_table :table_types do |t|
      t.string :type

      t.timestamps
    end
  end
end

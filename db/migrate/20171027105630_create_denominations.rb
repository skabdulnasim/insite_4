class CreateDenominations < ActiveRecord::Migration
  def change
    create_table :denominations do |t|
      t.string :name
      t.float :value
      t.integer :country_id

      t.timestamps
    end
  end
end

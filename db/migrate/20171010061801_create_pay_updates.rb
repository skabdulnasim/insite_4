class CreatePayUpdates < ActiveRecord::Migration
  def change
    create_table :pay_updates do |t|
      t.integer :unit_id
      

      t.timestamps
    end
  end
end

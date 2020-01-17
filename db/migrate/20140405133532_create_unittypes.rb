class CreateUnittypes < ActiveRecord::Migration
  def change
    create_table :unittypes do |t|

      t.timestamps
    end
  end
end

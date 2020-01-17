class CreateSimos < ActiveRecord::Migration
  def change
    create_table :simos do |t|

      t.timestamps
    end
  end
end

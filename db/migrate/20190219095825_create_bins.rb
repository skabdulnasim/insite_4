class CreateBins < ActiveRecord::Migration
  def change
    create_table :bins do |t|
      t.string :name
      t.float :height
      t.float :width
      t.float :breadth
      t.integer :row_no
      t.references :store_rack
      t.string :unique_identify_no

      t.timestamps
    end
    add_index :bins, :store_rack_id
  end
end

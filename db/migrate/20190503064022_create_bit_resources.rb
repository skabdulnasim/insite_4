class CreateBitResources < ActiveRecord::Migration
  def change
    create_table :bit_resources do |t|
      t.integer :bit_id
      t.integer :resource_id
      t.boolean :status

      t.timestamps
    end
  end
end

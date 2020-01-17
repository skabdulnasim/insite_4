class AddBitIdToResources < ActiveRecord::Migration
  def change
    add_column :resources, :bit_id, :integer
  end
end

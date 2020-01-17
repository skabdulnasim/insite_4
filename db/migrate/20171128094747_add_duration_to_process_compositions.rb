class AddDurationToProcessCompositions < ActiveRecord::Migration
  def up
  	add_column :process_compositions, :duration, :float
  end
  def down
  	remove_column :process_compositions, :duration, :float
  end
end

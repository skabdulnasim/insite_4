class AddPropertiesToPosTerminals < ActiveRecord::Migration
  def change
    add_column :pos_terminals, :properties, :hstore
  end
end

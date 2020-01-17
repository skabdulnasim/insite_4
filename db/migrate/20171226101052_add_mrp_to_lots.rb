class AddMrpToLots < ActiveRecord::Migration
  def change
    add_column :lots, :mrp, :float
  end
end

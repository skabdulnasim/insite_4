class AddSplitRoundoffToBills < ActiveRecord::Migration
  def change
    add_column :bills, :split_roundoff, :float
  end
end

class AddRoundoffToBills < ActiveRecord::Migration
  def change
    add_column :bills, :roundoff, :float
  end
end

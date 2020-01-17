class AddLotIdentificationToLots < ActiveRecord::Migration
  def change
    add_column :lots, :lot_indentification, :integer
  end
end

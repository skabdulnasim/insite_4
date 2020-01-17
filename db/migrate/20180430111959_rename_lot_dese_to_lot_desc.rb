class RenameLotDeseToLotDesc < ActiveRecord::Migration
  def change
  	rename_column :lots, :lot_dese, :lot_desc
  end
end

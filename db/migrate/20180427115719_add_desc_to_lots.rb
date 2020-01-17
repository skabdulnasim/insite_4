class AddDescToLots < ActiveRecord::Migration
  def change
    add_column :lots, :lot_dese, :text
  end
end

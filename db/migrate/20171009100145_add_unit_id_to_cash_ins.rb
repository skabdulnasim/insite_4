class AddUnitIdToCashIns < ActiveRecord::Migration
  def change
    add_column :cash_ins, :unit_id, :integer
  end
end


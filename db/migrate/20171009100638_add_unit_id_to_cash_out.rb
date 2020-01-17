class AddUnitIdToCashOut < ActiveRecord::Migration
  def change
    add_column :cash_outs, :unit_id, :integer
  end
end

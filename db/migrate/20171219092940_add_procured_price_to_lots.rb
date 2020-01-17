class AddProcuredPriceToLots < ActiveRecord::Migration
  def change
    add_column :lots, :procured_price, :float
  end
end

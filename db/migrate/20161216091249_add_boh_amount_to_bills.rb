class AddBohAmountToBills < ActiveRecord::Migration
  def change
    add_column :bills, :boh_amount, :float
  end
end

class AddAvailableAmountToPay < ActiveRecord::Migration
  def change
    add_column :pays, :available_amount, :float
  end
end

class RemoveAmountFromPays < ActiveRecord::Migration
  def up
    remove_column :pays, :amount
  end

  def down
    add_column :pays, :amount, :decimal
  end
end

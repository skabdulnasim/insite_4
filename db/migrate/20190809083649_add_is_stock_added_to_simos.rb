class AddIsStockAddedToSimos < ActiveRecord::Migration
  def change
    add_column :simos, :isStockAdded, :integer
  end
end

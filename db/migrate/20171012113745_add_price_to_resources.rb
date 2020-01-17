class AddPriceToResources < ActiveRecord::Migration
  def change
    add_column :resources, :price, :float
  end
end

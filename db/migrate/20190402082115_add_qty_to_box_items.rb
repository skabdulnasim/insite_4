class AddQtyToBoxItems < ActiveRecord::Migration
  def change
    add_column :box_items, :qty, :float
  end
end

class AddColorSizeModelToLots < ActiveRecord::Migration
  def change
    add_column :lots, :color, :string
    add_column :lots, :size, :string
    add_column :lots, :model, :string
  end
end

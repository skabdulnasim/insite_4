class AddColorIdSizeIdToStocks < ActiveRecord::Migration
  def change
    add_column :stocks, :color_id, :integer
    add_column :stocks, :size_id, :integer
  end
end

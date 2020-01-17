class AddDescriptionToStockDefinations < ActiveRecord::Migration
  def change
    add_column :stock_definations, :description, :text
  end
end

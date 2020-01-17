class AddMoreColumnsToStocks < ActiveRecord::Migration
  def change
  	add_column :stocks, :color_name, :string
  	add_column :stocks, :model_number, :string
  	add_column :stocks, :size, :string
  end
end

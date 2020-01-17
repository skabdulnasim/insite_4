class ChangeSizeToSizeNameInStocks < ActiveRecord::Migration
  def change
   rename_column :stocks, :size, :size_name
  end
end

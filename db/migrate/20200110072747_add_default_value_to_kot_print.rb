class AddDefaultValueToKotPrint < ActiveRecord::Migration
  def change
  	change_column :sorts, :kot_print, :string, default: 'yes'
  end
end

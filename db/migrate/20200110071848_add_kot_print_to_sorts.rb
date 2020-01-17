class AddKotPrintToSorts < ActiveRecord::Migration
  def change
    add_column :sorts, :kot_print, :string, :default => 'yes'
  end
end

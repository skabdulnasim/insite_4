class AddReprintCountToBills < ActiveRecord::Migration
  def change
    add_column :bills, :reprint_count, :integer, :default=>0
  end
end

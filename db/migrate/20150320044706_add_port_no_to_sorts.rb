class AddPortNoToSorts < ActiveRecord::Migration
  def change
    add_column :sorts, :port_no, :text
  end
end

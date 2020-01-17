class AddPaxToBills < ActiveRecord::Migration
  def change
    add_column :bills, :pax, :integer
  end
end

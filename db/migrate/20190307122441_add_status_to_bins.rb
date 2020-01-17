class AddStatusToBins < ActiveRecord::Migration
  def change
  	add_column :bins, :status, :string
  end
end

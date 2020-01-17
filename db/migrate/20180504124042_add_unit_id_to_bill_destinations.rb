class AddUnitIdToBillDestinations < ActiveRecord::Migration
  def change
    add_column :bill_destinations, :unit_id, :integer
  end
end

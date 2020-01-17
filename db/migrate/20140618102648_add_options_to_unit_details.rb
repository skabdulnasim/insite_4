class AddOptionsToUnitDetails < ActiveRecord::Migration
  def change
    add_column :unit_details, :options, :text
  end
end

class AddUnitIdToMenuMappings < ActiveRecord::Migration
  def change
  	add_column :menu_mappings, :unit_id, :integer
  end
end

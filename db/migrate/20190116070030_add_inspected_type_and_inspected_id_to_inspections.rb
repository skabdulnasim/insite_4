class AddInspectedTypeAndInspectedIdToInspections < ActiveRecord::Migration
  def change
    add_column :inspections, :inspected_entity_type, :string
    add_column :inspections, :inspected_entity_id, :integer
  end
end

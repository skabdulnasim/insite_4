class AddVisitedEntityTypeToVisitingHistories < ActiveRecord::Migration
  def change
    add_column :visiting_histories, :visited_entity_type, :string
    add_column :visiting_histories, :visited_entity_id, :integer
  end
end

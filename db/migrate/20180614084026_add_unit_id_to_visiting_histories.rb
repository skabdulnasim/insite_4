class AddUnitIdToVisitingHistories < ActiveRecord::Migration
  def change
    add_column :visiting_histories, :unit_id, :integer
  end
end

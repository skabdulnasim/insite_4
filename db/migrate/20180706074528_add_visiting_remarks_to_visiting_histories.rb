class AddVisitingRemarksToVisitingHistories < ActiveRecord::Migration
  def change
    add_column :visiting_histories, :visiting_remarks, :string
  end
end

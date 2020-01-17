class AddAggregationFunctionsToReports < ActiveRecord::Migration
  def change
    add_column :reports, :aggregation_functions, :string
  end
end

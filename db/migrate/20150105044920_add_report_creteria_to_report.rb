class AddReportCreteriaToReport < ActiveRecord::Migration
  def change
    add_column :reports, :report_criteria, :text
  end
end

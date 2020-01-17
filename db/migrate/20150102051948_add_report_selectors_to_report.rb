class AddReportSelectorsToReport < ActiveRecord::Migration
  def change
    add_column :reports, :report_selectors, :text
  end
end

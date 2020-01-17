class CreateReportPreferences < ActiveRecord::Migration
  def change
    unless table_exists?("report_preferences")
      create_table :report_preferences do |t|
        t.string :report_key
        t.text :allowed_attributes
        t.integer :unit_id

        t.timestamps
      end
    end
  end
end

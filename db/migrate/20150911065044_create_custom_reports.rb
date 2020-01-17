class CreateCustomReports < ActiveRecord::Migration
  def change
    create_table :custom_reports do |t|
      t.string :name
      t.text :query
      t.references :report_folder

      t.timestamps
    end
    add_index :custom_reports, :report_folder_id
  end
end

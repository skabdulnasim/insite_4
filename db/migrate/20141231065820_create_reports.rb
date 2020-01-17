class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.string :name
      t.references :report_folder

      t.timestamps
    end
    add_index :reports, :report_folder_id
  end
end

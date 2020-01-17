class CreateReportFolders < ActiveRecord::Migration
  def change
    create_table :report_folders do |t|
      t.string :name
      t.string :master_model
      t.string :related_models

      t.timestamps
    end
  end
end

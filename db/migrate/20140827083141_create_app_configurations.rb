class CreateAppConfigurations < ActiveRecord::Migration
  def change
    create_table :app_configurations do |t|
      t.string :config_key
      t.text :config_value

      t.timestamps
    end
  end
end

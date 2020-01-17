class CreateMasterModels < ActiveRecord::Migration
  def change
    create_table :master_models do |t|
      t.string :name
      t.string :status

      t.timestamps
    end
  end
end

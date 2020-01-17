class CreateMoreInfos < ActiveRecord::Migration
  def change
    create_table :more_infos do |t|
      t.string :name

      t.timestamps
    end
  end
end

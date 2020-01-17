class CreateUnitMoreInfos < ActiveRecord::Migration
  def change
    create_table :unit_more_infos do |t|
      t.integer :unit_id
      t.integer :more_info_id

      t.timestamps
    end
  end
end

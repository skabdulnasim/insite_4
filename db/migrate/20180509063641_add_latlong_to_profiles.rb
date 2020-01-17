class AddLatlongToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :latitude, :text
    add_column :profiles, :longitude, :text
  end
end

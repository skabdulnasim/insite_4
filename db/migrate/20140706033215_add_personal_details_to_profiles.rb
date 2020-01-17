class AddPersonalDetailsToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :address, :text
    add_column :profiles, :city, :text
    add_column :profiles, :state, :text
    add_column :profiles, :zip_code, :text
    add_column :profiles, :country, :string
  end
end

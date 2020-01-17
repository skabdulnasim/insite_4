class AddLatitudeLongitudeToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :latitude, :string
    add_column :vendors, :longitude, :string
  end
end

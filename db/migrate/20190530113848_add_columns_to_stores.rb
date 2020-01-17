class AddColumnsToStores < ActiveRecord::Migration
  def change
    add_column :stores, :latitude, :string
    add_column :stores, :longitude, :string
    add_column :stores, :gstn_no, :string
    add_column :stores, :pan_no, :string
    add_column :stores, :contact_person, :string
  end
end

class AddCountryToUnits < ActiveRecord::Migration
  def change
    add_column :units, :country, :string
  end
end

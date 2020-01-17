class AddDescriptionToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :latitude, :string
  end
end

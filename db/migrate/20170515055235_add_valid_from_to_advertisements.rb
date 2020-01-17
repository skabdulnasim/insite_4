class AddValidFromToAdvertisements < ActiveRecord::Migration
  def change
    add_column :advertisements, :description, :text
    add_column :advertisements, :valid_from, :date
    add_column :advertisements, :valid_till, :date
    add_column :advertisements, :position, :string
    add_column :advertisements, :repeating, :integer
  end
end

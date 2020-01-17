class AddTitleToInspections < ActiveRecord::Migration
  def change
    add_column :inspections, :title, :string
  end
end

class AddResourceTypeToBills < ActiveRecord::Migration
  def change
    add_column :bills, :resource_type, :string
  end
end

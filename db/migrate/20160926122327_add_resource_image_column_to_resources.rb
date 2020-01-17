class AddResourceImageColumnToResources < ActiveRecord::Migration
  def change
    add_attachment :resources, :resource_image
  end
end

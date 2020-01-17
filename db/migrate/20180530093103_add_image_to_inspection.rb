class AddImageToInspection < ActiveRecord::Migration
  def change
  	add_attachment :inspections, :image
  end
end

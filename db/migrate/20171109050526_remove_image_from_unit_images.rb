class RemoveImageFromUnitImages < ActiveRecord::Migration
	def change
		remove_column :unit_images, :image
	end
end
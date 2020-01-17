class AddAttachmentImageToUnitImages < ActiveRecord::Migration
  def self.up
    change_table :unit_images do |t|
      t.attachment :image
    end
  end

  def self.down
    remove_attachment :unit_images, :image
  end
end
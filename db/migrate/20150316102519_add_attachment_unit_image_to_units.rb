class AddAttachmentUnitImageToUnits < ActiveRecord::Migration
  def self.up
    change_table :units do |t|
      t.attachment :unit_image
    end
  end

  def self.down
    remove_attachment :units, :unit_image
  end
end

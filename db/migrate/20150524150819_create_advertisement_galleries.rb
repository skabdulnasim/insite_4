class CreateAdvertisementGalleries < ActiveRecord::Migration
  def change
    create_table :advertisement_galleries do |t|
      t.integer :advertisement_id
      t.attachment :advertisement_image

      t.timestamps
    end
  end
end

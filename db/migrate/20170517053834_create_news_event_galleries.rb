class CreateNewsEventGalleries < ActiveRecord::Migration
  def change
    create_table :news_event_galleries do |t|
      t.integer :news_event_id
      t.attachment :news_event_image

      t.timestamps
    end
  end
end
